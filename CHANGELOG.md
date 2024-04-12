# AWS Logs Ingest to Splunk CHANGELOG

## Minor Release 1.4.0

- Added r53 to splunk module

## Hotfix Release 1.3.2

- Fixed issue with parsing large events for WAF

## Hotfix Release 1.3.1

- Removed dependency on state machine to read s3 objects

## Minor Release 1.3.0

- Added support to forward waf logs

## Hotfix Release 1.2.1

- Fixed naming lookup for the Master organization
- Fixed naming of the newly created role in Master organization

## Minor Release 1.2.0

- Added new parameters (accountName, tenant) to the sent event
- Updated the lambda runtime to nodejs18.x

## Hotfix Release 1.1.1

- Updated secret path to be dynamic

## Minor Release 1.1.0

- Updated api token to be retrieved from vault
- Updated the secret to be replicated instead of creating in each region

## Hotfix Release 1.0.1

- Increased CloudWatch Log Group Retention
- Modified Email Subscription for SNS

## Major Release 1.0.0

- Initial Release
- Added Terraform Guard Duty Findings Ingest to Splunk Service
