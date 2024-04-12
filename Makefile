terraform_dir := terraform/

terraform_modules := modules/secrets_manager/ \
	 				 modules/sqs/ \
					 modules/step_function/ \

js_files := terraform/services/splunk-log-integration/regional_resources/waf-to-splunk/lambda_code/index.js \
            terraform/services/splunk-log-integration/regional_resources/r53-to-splunk/lambda_code/index.js

all: terraform-fmt terraform-docs eslint

terraform-fmt:
	@echo "Performing a Terraform format"
	terraform fmt --recursive terraform/

terraform-vld:
	@echo ""
	@echo "Performing a Terraform init on the ."
	terraform init --backend=false terraform/services/splunk-log-integration/global_resources
	terraform init --backend=false terraform/services/splunk-log-integration/global_logging_resources
	terraform init --backend=false terraform/services/splunk-log-integration/regional_resources/guardduty-to-splunk
	terraform init --backend=false terraform/services/splunk-log-integration/regional_resources/waf-to-splunk
	terraform init --backend=false terraform/services/splunk-log-integration/regional_resources/r53-to-splunk
	@echo ""
	@echo "Performing a Terraform Validate on the ."
	terraform validate terraform/services/splunk-log-integration/global_resources
	terraform validate terraform/services/splunk-log-integration/global_logging_resources
	terraform validate terraform/services/splunk-log-integration/regional_resources
	terraform validate terraform/services/splunk-log-integration/regional_resources/guardduty-to-splunk
	terraform validate terraform/services/splunk-log-integration/regional_resources/waf-to-splunk
	terraform validate terraform/services/splunk-log-integration/regional_resources/r53-to-splunk

terraform-docs:
	@echo ""
	@echo "Updating Terraform Module Documentation"
	for i in $(terraform_modules); do \
		echo "Updating README" $(terraform_dir)/$$i; \
		terraform-docs markdown $(terraform_dir)/$$i > $(terraform_dir)/$$i/README.md; \
	done;

	@echo ""
	@echo "Updating Terraform Guard Duty Findings Ingest to Splunk Service Documentation"
	@echo ""
	printf "$$(terraform-docs markdown terraform/services/splunk-log-integration/global_resources)" > terraform/services/splunk-log-integration/global_resources/README.md
	printf "\n\n## hcl .tfvars file format" >> terraform/services/splunk-log-integration/global_resources/README.md
	printf '\n\n```\n' >> terraform/services/splunk-log-integration/global_resources/README.md
	printf "$$(terraform-docs tfvars hcl terraform/services/splunk-log-integration/global_resources)" >> terraform/services/splunk-log-integration/global_resources/README.md
	printf '\n```' >> terraform/services/splunk-log-integration/global_resources/README.md

	printf "$$(terraform-docs markdown terraform/services/splunk-log-integration/global_logging_resources)" > terraform/services/splunk-log-integration/global_logging_resources/README.md
	printf "\n\n## hcl .tfvars file format" >> terraform/services/splunk-log-integration/global_logging_resources/README.md
	printf '\n\n```\n' >> terraform/services/splunk-log-integration/global_logging_resources/README.md
	printf "$$(terraform-docs tfvars hcl terraform/services/splunk-log-integration/global_logging_resources)" >> terraform/services/splunk-log-integration/global_logging_resources/README.md
	printf '\n```' >> terraform/services/splunk-log-integration/global_logging_resources/README.md

	printf "$$(terraform-docs markdown terraform/services/splunk-log-integration/regional_resources/guardduty-to-splunk)" > terraform/services/splunk-log-integration/regional_resources/guardduty-to-splunk/README.md
	printf "\n\n## hcl .tfvars file format" >> terraform/services/splunk-log-integration/regional_resources/guardduty-to-splunk/README.md
	printf '\n\n```\n' >> terraform/services/splunk-log-integration/regional_resources/guardduty-to-splunk/README.md
	printf "$$(terraform-docs tfvars hcl terraform/services/splunk-log-integration/regional_resources/guardduty-to-splunk)" >> terraform/services/splunk-log-integration/regional_resources/guardduty-to-splunk/README.md
	printf '\n```' >> terraform/services/splunk-log-integration/regional_resources/guardduty-to-splunk/README.md

	printf "$$(terraform-docs markdown terraform/services/splunk-log-integration/regional_resources/waf-to-splunk)" > terraform/services/splunk-log-integration/regional_resources/waf-to-splunk/README.md
	printf "\n\n## hcl .tfvars file format" >> terraform/services/splunk-log-integration/regional_resources/waf-to-splunk/README.md
	printf '\n\n```\n' >> terraform/services/splunk-log-integration/regional_resources/waf-to-splunk/README.md
	printf "$$(terraform-docs tfvars hcl terraform/services/splunk-log-integration/regional_resources/waf-to-splunk)" >> terraform/services/splunk-log-integration/regional_resources/waf-to-splunk/README.md
	printf '\n```' >> terraform/services/splunk-log-integration/regional_resources/waf-to-splunk/README.md
    
	printf "$$(terraform-docs markdown terraform/services/splunk-log-integration/regional_resources/r53-to-splunk)" > terraform/services/splunk-log-integration/regional_resources/r53-to-splunk/README.md
	printf "\n\n## hcl .tfvars file format" >> terraform/services/splunk-log-integration/regional_resources/r53-to-splunk/README.md
	printf '\n\n```\n' >> terraform/services/splunk-log-integration/regional_resources/r53-to-splunk/README.md
	printf "$$(terraform-docs tfvars hcl terraform/services/splunk-log-integration/regional_resources/r53-to-splunk)" >> terraform/services/splunk-log-integration/regional_resources/r53-to-splunk/README.md
	printf '\n```' >> terraform/services/splunk-log-integration/regional_resources/r53-to-splunk/README.md

eslint:
	@echo ""
	@echo "linting JS files"
	for i in $(js_files); do \
		echo "validating" $$i; \
		npx eslint $$i; \
	done;
	
