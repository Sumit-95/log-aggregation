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

const AWS = require('aws-sdk');
const s3 = new AWS.S3();
const zlib = require('zlib');



const loggerConfig = {
	url: process.env.SPLUNK_HEC_URL,
	token: process.env.SPLUNK_HEC_TOKEN_PATH,
}

async function retriveSplunkToken() {
	
	// Retrieve the AWS region from the environment variable
	const region = process.env.AWS_DEFAULT_REGION;
  
	// Create a Secrets Manager client with the specified region
	const secretsManager = new AWS.SecretsManager({ region });
  
	// Define the parameters for retrieving the secret
	const params = {
	  SecretId: process.env.SPLUNK_HEC_TOKEN_PATH
	};
  
	try {
	  // Retrieve the secret value
	  const data = await secretsManager.getSecretValue(params).promise();
	  
	  // Parse and return the secret value
	  const secret  = data.SecretString;
	  
      return secret;
	} catch (error) {
	  console.error("Error retrieving secret:", error);
	  throw error;
	}
}

const accountNameQuery = async function(accountId) {
	// Create STS client
	const stsClient = new AWS.STS({ region: 'us-east-1' });
	const orgAccountId = process.env.ORG_ADMIN_ACCOUNT_NUMBER;
	const loggingRoleName = process.env.ORG_ADMIN_LOGGING_STS_ROLE;

	// Assume role to get session credentials
	const assumeRoleParams = {
		RoleArn: `arn:aws:iam::${orgAccountId}:role/${loggingRoleName}`,
		RoleSessionName: `${loggingRoleName}`
	};
	try {
		// Call AssumeRole to get temporary credentials
		const assumeRoleResponse = await stsClient.assumeRole(assumeRoleParams).promise();
		// Extract session credentials
		const { AccessKeyId, SecretAccessKey, SessionToken } = assumeRoleResponse.Credentials;
		// Create Organizations client using session credentials
		const orgs = new AWS.Organizations({
			accessKeyId: AccessKeyId,
			secretAccessKey: SecretAccessKey,
			sessionToken: SessionToken,
			region: 'us-east-1'
		});
		try {
			console.log('Retrieving account names under the organization...');
			// Call listAccounts to retrieve account details under the organization
			const orgAccountsResponse = await orgs.listAccounts().promise();

			// Finding the account name corresponding to the provided account ID
			const account = orgAccountsResponse.Accounts.find(account => account.Id === accountId);
			if (account) {
				console.log('Found name for account ID', accountId, ':', account.Name);
				return account.Name;
			} else {
				console.log('Account with ID', accountId, 'not found, Processing with Unknown');
				return 'unknown';
			}
		} catch (error) {
			console.log(`Unable to get name for account ID ${accountId}`)
		}  
	} catch (error) {
		console.log(`Unable to obtain credentials for ${assumeRoleParams.RoleArn}`)
	}
}

async function getFileContentFromS3(bucketName, key) {
	try {
		// Retrieve the file from S3
		console.log('Download the .gz file from S3');
        const params = {
            Bucket: bucketName,
            Key: key
        };
		const { Body } = await s3.getObject(params).promise();

		// Decompress the .gz file
        const decompressedData = zlib.gunzipSync(Body);

		// Convert the file content to a string
		const fileContent = decompressedData.toString('utf-8');

		return fileContent
	} catch (error) {
		console.error('Error retrieving file from S3:', error)
		throw new Error('Failed to retrieve file from S3')
	}
}

// Helper function to convert stream to string
async function streamToString(stream) {
	const chunks = []
	return new Promise((resolve, reject) => {
		stream.on('data', (chunk) => chunks.push(chunk))
		stream.on('end', () => resolve(Buffer.concat(chunks).toString('utf-8')))
		stream.on('error', (error) => reject(error))
	})
}

function parseLogEvent(logfileContent){
	const eventList = logfileContent.split('\n').filter(Boolean).map(JSON.parse)
    
	return eventList
}

const SplunkLogger = require('./lib/mysplunklogger')

exports.handler = (event, context, callback) => {
	let bucketName, key;

	// Extracting the object key from the event
	console.log('Extracting the object key from the event');
	console.log('Triggered Lambda', event)

	try {
		// SQS event
		const body = JSON.parse(event.Records[0].body);
		console.log("Parsed Body from SQS Event");
	
		bucketName = body.detail.requestParameters.bucketName;
		key = body.detail.requestParameters.key;
	} catch (sqsError) {
		try {
			// Direct invocation event
			const { requestParameters } = event.detail;

			console.log('Direct Invocation Event');
			bucketName = requestParameters.bucketName;
			key = requestParameters.key;
		} catch (directError) {
			console.log('Unknown event format');
		}

	}

	console.log("S3 Bucket Name:", bucketName);
	console.log("S3 Key:", key);
	
	//get raw data from S3 path and bucket as in event
	getFileContentFromS3(bucketName, key)
	.then(fileContent => {
		console.log('Successfully Read S3 File');
	})
	.catch(error => {
		console.error('Error handling request:', error)
		callback(error); // Ensure to propagate the error to the caller
	});
   
	console.log('Successfully got data from', key)

	var accountName
	//set base vars requested by gsoc
	const tenantName = 'abcd'
	const sourcetype = 'aws:route53'
    
	//get splunk token
	retriveSplunkToken().then((SplunkToken) => {
        
		console.log('splunk token was retrieved successfully')
			
			//get raw data from S3 path and bucket as in event
			
			getFileContentFromS3(bucketName, key).then((fileContent) => {
			console.log(`data was retrieved successfully from path ${key}`)
          
			var logEvents = parseLogEvent(fileContent)

			if (Object.keys(logEvents).length > 0) {
            
				console.log('file contains events, contuing to parse')
				console.log('file contains events', logEvents)
            
				loggerConfig.token = SplunkToken
				const logger = new SplunkLogger(loggerConfig)
				const tenantAccountID=logEvents[0]['account_id']
				console.log(tenantAccountID)
            
				accountNameQuery(tenantAccountID).then((accountName) => {
					logEvents.forEach((logEvent, index) => {
                
						console.log(`processing event at #${index} of ID`) 
						//console.log(`Appending additional parameters to the event (accountName: ${accountName}, tenant: ${tenantName})`)
    					var event_to_log = {
					        time: Date.now(),
					        source: `lambda:${context.functionName}`,
					        sourcetype: sourcetype,
					        event: logEvent,
					        accountName: accountName,
					        tenant: tenantName
					    };
                    
						logger.log(event_to_log)

					})
					
					logger.flushAsync((error, response) => {
				        if (error) {
				            callback(error);
				        } else {
				            console.log(`Response from Splunk:\n${response}`);
				            callback(null, event.key1); // Echo back the first key value
				        }
				    });
				    return {
						statusCode: 200,
						body: {body: 'data was successfully sent to splunk'},
					}
                
				}).catch((error) => {
					return {
						statusCode: 500,
						body: JSON.stringify({ error: 'Failed to Processing Splunk Forwarder Task'}),
					}
                
				})       
            
			}
			else{
				console.error('the provided log file is emptry')
				return {
					statusCode: 500,
					body: JSON.stringify({ error: 'empty_file at', key}),
				}

			}
    
		}).catch((error) => {
			console.error('Error handling request:', error)
			return {
				statusCode: 500,
				body: JSON.stringify({ error: `File not accessible in S3 at, ${key}`}),
			}
        
        
		})
        
	}).catch((error) => {
		console.error('Error handling request:', error)
		return {
			statusCode: 500,
			body: JSON.stringify({ error: 'unable to get splunk token from secrets manager'}),
		}
        
	})
    
   
}
