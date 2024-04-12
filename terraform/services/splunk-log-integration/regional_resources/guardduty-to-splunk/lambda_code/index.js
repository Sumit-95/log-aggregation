/**
 * Splunk logging for AWS Lambda
 *
 * This function logs to a Splunk host using Splunk's HTTP event collector API.
 *
 * Define the following Environment Variables in the console below to configure
 * this function to log to your Splunk host:
 *
 * 1. SPLUNK_HEC_URL: URL address for your Splunk HTTP event collector endpoint.
 * Default port for event collector is 8088. Example: https://host.com:8088/services/collector
 *
 * 2. SPLUNK_HEC_TOKEN: Token for your Splunk HTTP event collector.
 * To create a new token for this Lambda function, refer to Splunk Docs:
 * http://docs.splunk.com/Documentation/Splunk/latest/Data/UsetheHTTPEventCollector#Create_an_Event_Collector_token
 *
 * In addition, the following Environment Variables should also be defined
 * in order to fetch the account name of the source AWS Account:
 *
 * 3. ORG_ADMIN_ACCOUNT_NUMBER: Admin account ID.
 * 
 * 4. ORG_ADMIN_LOGGING_STS_ROLE: The role to assume in the Admin account.
 */
const loggerConfig = {
    url: process.env.SPLUNK_HEC_URL,
    token: process.env.SPLUNK_HEC_TOKEN_PATH,
};

function retriveSplunkToken() {
    const { SecretsManagerClient, GetSecretValueCommand} = require("@aws-sdk/client-secrets-manager");

    let SplunkToken = null;
    const secretsManagerClient = new SecretsManagerClient({ region: process.env.AWS_DEFAULT_REGION});
    const params = {
        SecretId: process.env.SPLUNK_HEC_TOKEN_PATH
    };

    return new Promise(async (resolve, reject) => {
        secretsManagerClient.send(new GetSecretValueCommand(params))
        .then ((data) => {
            
            SplunkToken = data.SecretString;
            if (SplunkToken === null) {
                throw 'SplunkToken is null';
            } else {
                resolve(SplunkToken);
            };
        })
        .catch((error) => {
            console.log(error, error.stack);
            reject(error);
        });
    });
}

const accountNameQuery = async function(accountId) {
    const { STSClient, AssumeRoleCommand} = require("@aws-sdk/client-sts");
    const { OrganizationsClient, DescribeAccountCommand} = require("@aws-sdk/client-organizations");

    const orgAccountId = process.env.ORG_ADMIN_ACCOUNT_NUMBER;
    const loggingRoleName = process.env.ORG_ADMIN_LOGGING_STS_ROLE;

    const stsClient = new STSClient();
    const assumeRoleParams = {
        RoleArn: `arn:aws:iam::${orgAccountId}:role/${loggingRoleName}`,
        RoleSessionName: `${loggingRoleName}`
    };

    return new Promise((resolve, reject) => {
        stsClient.send(new AssumeRoleCommand(assumeRoleParams))
        .then((data) => {
            console.log('Successfully obtained credentials for ',assumeRoleParams.RoleArn);

            const sessionCredentials = {
                accessKeyId: data.Credentials.AccessKeyId,
                secretAccessKey: data.Credentials.SecretAccessKey,
                sessionToken: data.Credentials.SessionToken,
            };

            const organizationsClient = new OrganizationsClient({credentials: sessionCredentials,region: 'us-east-1'});

            organizationsClient.send(new DescribeAccountCommand({AccountId: accountId}))
            .then((data2) => {
                var accountName = data2.Account.Name;
                console.log('Found name for account ID ',accountId,': ',accountName);
                resolve(accountName);
            })
            .catch((error2) => {
                reject(`Unable to get name for account ID ${accountId}\n${error2}${error2.stack}`);
            });
        })
        .catch((error) => {
            reject(`Unable to obtain credentials for ${assumeRoleParams.RoleArn}\n${error}${error.stack}`);
        });
    });
};

const SplunkLogger = require('./lib/mysplunklogger');

//const logger = new SplunkLogger(loggerConfig);

exports.handler = (event, context, callback) => {
    console.log('Retrieving Splunk token');
    retriveSplunkToken().then((SplunkToken) => {
        loggerConfig.token = SplunkToken;
        const logger = new SplunkLogger(loggerConfig);

        // Check if the event contains a "Records" key or not
        // because sometimes the event structure is Records[{"body":{}}]
        var containsRecords;
        var accountIdEntry;
        var parsedEventBody;
        if ("Records" in event) {
            containsRecords = true;
            parsedEventBody = JSON.parse(event.Records[0].body);
            accountIdEntry = parsedEventBody.detail.accountId;
        } else {
            containsRecords = false;
            accountIdEntry = event.detail.accountId;
        };
        console.log(`Obtaining additional parameters (accountName for ${accountIdEntry}, tenant)`);
        const tenantName = 'LSEG';
        accountNameQuery(accountIdEntry).then((accountName) => {
            
            console.log(`Appending additional parameters to the event (accountName: ${accountName}, tenant: ${tenantName})`);

            if (containsRecords === true) {
                parsedEventBody.detail.accountName = accountName;
                parsedEventBody.tenant = tenantName;
                event = parsedEventBody;
            } else {
                event.detail.accountName = accountName;
                event.tenant = tenantName;
            };
            
            console.log('Received event:', JSON.stringify(event,null,2));

            // Log JSON objects to Splunk
            logger.log(event);

            // Log JSON objects with optional 'context' argument (recommended)
            // This adds valuable Lambda metadata including functionName as source, awsRequestId as field
            //logger.log(event, context);

            // Log strings
            //logger.log(`value1 = ${event.key1}`, context);

            // Log with user-specified timestamp - useful for forwarding events with embedded
            // timestamps, such as from AWS IoT, AWS Kinesis, AWS CloudWatch Logs
            // Change "Date.now()" below to event timestamp if specified in event payload
            //logger.logWithTime(Date.now(), event, context);

            // Advanced:
            // Log event with user-specified request parameters - useful to set input settings per event vs token-level
            // Full list of request parameters available here:
            // http://docs.splunk.com/Documentation/Splunk/latest/RESTREF/RESTinput#services.2Fcollector
            //logger.logEvent({
            //    time: Date.now(),
            //    host: 'serverless',
            //    source: `lambda:${context.functionName}`,
            //    sourcetype: 'httpevent',
            //    event: event,
            //});

            // Send all the events in a single batch to Splunk
            logger.flushAsync((error, response) => {
                if (error) {
                    callback(error);
                } else {
                    console.log(`Response from Splunk:\n${response}`);
                    callback(null, event.key1); // Echo back the first key value
                }
            });
        }).catch((error) => {
            const defaultAccountName = "unknown";
            console.log(`Unable to obtain additional parameters\nContinuing with the default values (accountName: ${defaultAccountName}, tenant: ${tenantName})\n${error}`);

            if (containsRecords === true) {
                parsedEventBody.detail.accountName = defaultAccountName;
                parsedEventBody.tenant = tenantName;
                event = parsedEventBody;
            } else {
                event.detail.accountName = defaultAccountName;
                event.tenant = tenantName;
            };
            
            console.log('Received event:', JSON.stringify(event,null,2));
            logger.log(event);
            logger.flushAsync((error, response) => {
                if (error) {
                    callback(error);
                } else {
                    console.log(`Response from Splunk:\n${response}`);
                    callback(null, event.key1); // Echo back the first key value
                };
            });
        });
    });
};
