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
}

function retriveSplunkToken() {
	const { SecretsManagerClient, GetSecretValueCommand} = require('@aws-sdk/client-secrets-manager')

	let SplunkToken = null
	const secretsManagerClient = new SecretsManagerClient({ region: process.env.AWS_DEFAULT_REGION})
	const params = {
		SecretId: process.env.SPLUNK_HEC_TOKEN_PATH
	}

	return new Promise( (resolve, reject) => {
		secretsManagerClient.send(new GetSecretValueCommand(params))
			.then ((data) => {

				SplunkToken = data.SecretString
				if (SplunkToken === null) {
					throw 'SplunkToken is null'
				} else {
					resolve(SplunkToken)
				}
			})
			.catch((error) => {
				console.log(error, error.stack)
				reject(error)
			})
	})
}

const accountNameQuery = async function(accountId) {
	const { STSClient, AssumeRoleCommand} = require('@aws-sdk/client-sts')
	const { OrganizationsClient, DescribeAccountCommand} = require('@aws-sdk/client-organizations')

	const orgAccountId = process.env.ORG_ADMIN_ACCOUNT_NUMBER
	const loggingRoleName = process.env.ORG_ADMIN_LOGGING_STS_ROLE

	const stsClient = new STSClient()
	const assumeRoleParams = {
		RoleArn: `arn:aws:iam::${orgAccountId}:role/${loggingRoleName}`,
		RoleSessionName: `${loggingRoleName}`
	}

	return new Promise((resolve, reject) => {
		stsClient.send(new AssumeRoleCommand(assumeRoleParams))
			.then((data) => {
				console.log('Successfully obtained credentials for ',assumeRoleParams.RoleArn)

				const sessionCredentials = {
					accessKeyId: data.Credentials.AccessKeyId,
					secretAccessKey: data.Credentials.SecretAccessKey,
					sessionToken: data.Credentials.SessionToken,
				}

				const organizationsClient = new OrganizationsClient({credentials: sessionCredentials,region: 'us-east-1'})

				organizationsClient.send(new DescribeAccountCommand({AccountId: accountId}))
					.then((data2) => {
						var accountName = data2.Account.Name
						console.log('Found name for account ID ',accountId,': ',accountName)
						resolve(accountName)
					})
					.catch((error2) => {
						reject(`Unable to get name for account ID ${accountId}\n${error2}${error2.stack}`)
					})
			})
			.catch((error) => {
				reject(`Unable to obtain credentials for ${assumeRoleParams.RoleArn}\n${error}${error.stack}`)
			})
	})
}

async function getFileContentFromS3(bucketName, key) {
	const { S3Client, GetObjectCommand } = require('@aws-sdk/client-s3')
	// create new s3 client
	const s3Client = new S3Client()
	// Specify the S3 getObject parameters
	const params = {
		Bucket: bucketName,
		Key: key,
	}
	try {
		// Retrieve the file from S3
		const s3Response =  await s3Client.send(new GetObjectCommand(params))
		// Convert the file content to a string
		const fileContent =  streamToString(s3Response.Body)
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

	const bucketName = event.detail.requestParameters.bucketName
	const key = event.detail.requestParameters.key

	console.log('Successfully got data from', key)
   
	var accountName
	//set base vars requested by gsoc
	const tenantName = 'LSEG'
	const sourcetype = 'aws:waf'
	//get raw data from S3 path and bucket as in event
	// 
    
	//get splunk token
	retriveSplunkToken().then((SplunkToken) => {
        
		console.log('splunk token was retrieved successfully')
		getFileContentFromS3(bucketName, key).then((fileContent) => {
			console.log(`data was retrieved successfully from path ${key}`)
          
			var logEvents = parseLogEvent(fileContent)

			if (Object.keys(logEvents).length > 0) {
            
				console.log('file contains events, contuing to parse')
            
				loggerConfig.token = SplunkToken
				const logger = new SplunkLogger(loggerConfig)
				const tenantAccountID=logEvents[0]['webaclId'].split(':')[4]
				console.log(tenantAccountID)
            
				accountNameQuery(tenantAccountID).then((accountName) => {
					logEvents.forEach((logEvent, index) => {
                
						console.log(`processing event at #${index} of ID` ,logEvent.httpRequest.requestId) 
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
				            //callback(null, event.key1); // Echo back the first key value
				        }
				    });
				    return {
						statusCode: 200,
						body: {body: 'data was successfully sent to splunk'},
					}
                
				}).catch(() => {
					console.log(`Unable to find account name for ${tenantAccountID} proceeding with unknown`)
					accountName = 'unknown'
					logEvents.forEach((logEvent, index) => {
                
						console.log(`processing event at #${index} of ID` ,logEvent.httpRequest.requestId) 
						//console.log(`Appending additional parameters to the event (accountName: ${accountName}, tenant: ${tenantName})`)
    
    					var event_to_log = {
					        timeforwarded: Date.now(),
					        sourcetype: sourcetype,
					        event: logEvent,
					        accountName: accountName,
					        tenant: tenantName
					    };
                    
						logger.log(event_to_log)
						//console.log(event_to_log)

					})
					// send events
					logger.flushAsync((error, response) => {
				        if (error) {
				            callback(error);
				        } else {
				            console.log(`Response from Splunk:\n${response}`);
				            //callback(null, event.key1); // Echo back the first key value
				        }
				    });
					return {
						statusCode: 200,
						body: {body: "events sent to splunk"},
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
