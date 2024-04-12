# Jenkins

## Content

* [Jenkins Pipelines Location](#location)
* [build.jenkinsFile](#build)

<a name="location"></a>

## Jenkins Pipelines Location

The following jenkins pipeline is deployed within the: 
* [Cloud Engineering/Jenkins/Dev/Security Services Space](https://cjcm-cet.660474218557.ew2.aws.prod.r53:8443/job/Cloud_Engineering/job/Dev/job/AWS/job/security_services/job/aws_logs_to_splunk_service/)

* [Cloud Engineering/Jenkins/Test/Security Services Space](https://cjcm-cet.660474218557.ew2.aws.prod.r53:8443/job/Cloud_Engineering/job/Test/job/AWS/job/security_services/job/aws_logs_to_splunk_service/)

* [Cloud Engineering/Jenkins/Master/Security Services Space](https://cjcm-cet.660474218557.ew2.aws.prod.r53:8443/job/Cloud_Engineering/job/Master/job/AWS/job/security_services/job/aws_logs_to_splunk_service/)

<a name="build"></a>

## aws-logs-to-splunk-service.jenkinsFile

This jenkins pipeline deploys the AWS Resources to push the GuardDuty Findings to Splunk.

### Job Configuration

| Parameter Type | Parameter Name | Default Value |
|--------|---------|---------|
| String | aws_admin_account_name | AWS-BSL-{environment}-ADMIN|
| String | aws_logging_account_name | AWS-BSL-LOGGING-{environment} |
| String | branch_name | {corresponding environment branch} |
| Choice | terraform_action | plan |
| Extended Choice | terraform_roles | |
| Extended Choice | deployments | |
| Hidden | aws_org_role | bsl-{organization}-admin-fulladmin-adfs-role |
| Hidden | terraform_path | /lseg/jenkins/tools/terraform/terraform_1.3.9 |
| Choice | aws_regions | |