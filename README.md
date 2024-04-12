# AWS Logs to Splunk Service

## Overview

The aim of this service is to make GuardDuty Findings available for Splunk, 
which is a centralised SIEM tool.

This service creates a CloudWatch Event Rule which is triggered by GuardDuty Findings, 
which in turn triggers a Step Function which orchestrate the entire flow. First Lambda Function will be invoked inside the Step Function, which Ingest the GuardDuty Findings to Splunk. If that failed for any reason, retry will be happen 3 times and afterwards GuardDuty Findings will be send to SQS Queue, there it will be kept for 14 days and retrying with the same Lambda Function. Also in the failed instance, Step Function will trigger an SNS Alerts to the respected teams for further troubleshooting.

## Content

* [Design](#design)
* [Repository Contents](#repository-contents)
    * [Jenkins Files](#jenkins-files)
    * [Python helpers](#python-helpers)
    * [Terraform](#terraform)
* [Operational Regions](#operational-regions)
* [Dependencies](#dependencies)
* [Testing](#testing)
* [GSOC Contact Information](#gsoc-contact-information)
* [Changelog](#changelog)
* [Contributing](#contributing)

<a name="design"></a>

## Design

| Type | Link |
|--------|---------|
| Design Diagram | [GuardDuty To Splunk](images/guardduty-to-splunk.jpg) |

<a name="repository-contents"></a>

## Repository Contents

<a name="jenkins-files"></a>

### Jenkins Pipelines

There are multiple stages to this deployment, for more information please 
see [Jenkins Files](jenkins-files/README.md).

<a name="terraform"></a>

### Terraform Modules

There are multiple Terradorm Modules for this service, for more information 
please see [Terraform Modules](terraform).

<a name="operational-regions"></a>

## Operational Regions

This service needs to be deployed into all operational regions. Please note that
as of March 20th, 2019 new regions added to AWS are not made available by 
default, please see: [Managing AWS Regions](https://docs.aws.amazon.com/general/latest/gr/rande-manage.html)
So unless a region, made available after March 20th, 2019 is approved by abcd, 
we do not need to deploy this service to those regions.

Below is a list of regions that this service is deployed to:

- us-east-1
- us-east-2
- us-west-1
- us-west-2
- ap-south-1
- ap-southeast-1
- ap-southeast-2
- ap-northeast-1
- ap-northeast-2
- ca-central-1
- eu-central-1
- eu-west-1
- eu-west-2
- eu-west-3
- eu-north-1
- sa-east-1

<a name="dependencies"></a>

## Requirements and Dependencies

### Cyber Security Operations - Threat Detection Engineering

The Splunk HTTP Event Collector URL (SPLUNK_HEC_URL) & Token (SPLUNK_HEC_TOKEN) are managed by the Cyber Security Security Operations - Threat Detection Engineering.

__Contact Email:__ CyberSecurity_SecurityOperations_CTD@abcd.com


<a name="testing"></a>

## Testing

__N.B.__ You require __terraform__ and __pylint__ to be installed to be able to 
run the Makefile.

There is a Makefile that is configured to perform:
- Terraform fmt on all Terraform scripts
    - `make terraform-fmt`
- Terraform Docs on all Terraform Modules
    - `make terraform-docs`

<a name="gsoc-contact-information"></a>

## GSOC Team

If any changes are made to this service, please ensure that the GSOC team are informed so 
as to update their dashboard feed on Splunk.

__GSOC Contact Email:__ gsoc@abcd.com

<a name="changelog"></a>

## Changelog

For a summary of version releases of this repository, please see the 
[CHANGELOG](CHANGELOG.md).

<a name="contributing"></a>

## Contributing

To contribute, please see the [CONTRIBUTING](CONTRIBUTING.md) file.