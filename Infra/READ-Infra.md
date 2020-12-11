# Infrastructure code

This repository includes all the Infrastructure as Code modulesincluding SaltSatck, Terraform, Docker 

## Warning
* NEVER make this repo or any part of it available publicly in any way
* AVOID placing credentials, keys, secrets or other sensitive information in this repo
* Use **terraform 12**

* Before committing use the command: 
    * ```terraform fmt``` in all the files to ensure consistent spacing and indentation
    * ``` terraform validate ``` in all the files to ensure validates the configuration files
* When create a PR, run ```terraform plan``` and attach to MR. 
* To merge the PR you must compliance the following:
    * Run the ```terraform apply``` in a infra QA session
    * Everything works as expected
