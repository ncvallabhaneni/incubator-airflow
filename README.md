# Test enviroment for Airflow

## Prerequisites

- Docker
- docker-compose
- Python 3.6.4

## Development

### Getting Started

1. This command should initialize the DB `docker-compose -f docker-compose-db-initialise.yml up`
1. Brings up the airflow-web(app) with Postgres and Redis services `docker-compose up`
2. visit http://localhost:8080

### Changes made to the repo

1. Terraform - Added Terraform config which will provision EC2 classic instance, ELB,RDS (Postgress), security groups for the EC2 instance, RDS and ELB and Auto scaling upto 10 EC2 instances. (Config has no errors but havent tested to provision on AWS)
2. Ansible - Added ansible config which will install docker and docker-compose on EC2 instances and its triggered by Terraform local provisioner. (Config has no errors but havent tested to provision on AWS)
3. Docker - Made some changes to Dockerfile to remove Kubernetes package and add custom airflow.cfg file.
4. Docker - Changes to bootstrap.sh file to make it work with our docker-comspoe files
5. Docker - Added docker-compose files to initialise the DB and bring up the stack with services airflow-web, airflow-postgres and redis. (Tested and working)

Commits:
`https://github.com/ncvallabhaneni/incubator-airflow/commit/ba96751540967d44e3627d4a3d2e13cd34a23d4e`
`https://github.com/ncvallabhaneni/incubator-airflow/commit/ab97e6f2a05734f4283ef7666553b08dbcb27be9`

There is bug in github UI which shows the second commit above done by someone else but if you checkout the repo and check `git log` it should show the right name `nikhil`

### To Do - Improvements 

1. Terraform config can be modified to work with VPC giving EC2 and RDS instances separate subnets which can then communicate using a NAT Gateway.
2. Travis CI can be implimented to deploy automatically (This supposed to be simple task but due to time constraints concentrated on getting config work so havent included it)
3. Ansible - The DB could be provisioned by Ansible rather in Terraform so the creds can be stored in a secure place for example as next point.
4. Secrets management - Implementation for some kind of secret management to hold stuff like DB credentails which are in plain text at the moment. Tools recommended Hasicorp Vault or Ansible Vault (To encrypt var files)


### Path to CI Files 

```
Docker files:
incubator-airflow/scripts/ci/kubernetes/docker

Terraform config:
/incubator-airflow/scripts/ci/terraform

Ansible Config:
/incubator-airflow/scripts/ci/ansible

```

## Environment Variables

| Variable | Description | Options | Required? |
|:---------|:------------|:--------|:----------|
| `LAUNCH_PROCESS` | To select which service to Run  | webserver/scheduler | Yes |
| `INITIALISE` | Used for database initializing | true/false | yes |

