# Fanmode Base Template

 * [Requirements](#requirements)
    * [Tooling](#tooling)
    * [Access](#access)
    * [Scaffolding](#scaffolding)
 * [Terraform Variables](#terraform-variables)
 * [Provisioning](#provisioning)

## Requirements

### Tooling

* ansible
* ansible-galaxy
* terraform
* terraform-inventory
* git
* linode-cli
* make

### Access

* Gitlab access
* Linode access (permissions)

### Scaffolding

The following environment variables needs to be set for the provisioning;

```
AWS_ACCESS_KEY_ID
AWS_SECRET_ACCESS_KEY
ANSIBLE_SSH_USER
```

## Solution Terraform Variables

Environment and instance specifics are defined in each solutions `stage.tfvars` and `prod.tfvars` in the `environments/solution/{stage,prod}` directories.

## Provisioning

The provisioning makes use of the ssh agent. Ensure both your regular ssh key as well as the key for the centos7 user has been loaded into your ssh agent.

To cater for instances where your local username and username that is provisioned via URM on remote systems do not match, the provisioning expects the following environment variable to be set to the value of your remote username.

Additionally, we're storing state into the etcd cluster and in order to do so, we need to provide paths to the relevant certificates via the exported environment variables.

```
export TF_VAR_S3_ACCESS_KEY=AWS_ACCESS_KEY_ID
export TF_VAR_S3_SECRET_KEY=AWS_SECRET_ACCESS_KEY
export TF_VAR_ANSIBLE_SSH_USER=ANSIBLE_SSH_USER

```

The code caters for both staging and production environments. You need to ensure you pass in the correct environment, project name and region which you want to build.

For example, standing up the infrastructure for a given solution;

```
make ENVIRONMENT=stage NAME=nexus REGION=eu-west apply
```

To run the relevant ansible playbooks against the solution;

```
make ENVIRONMENT=stage NAME=nexus REGION=eu-west ansible
```

For updates on a deployed solution;

```
make ENVIRONMENT=stage NAME=nexus REGION=eu-west update
```

It's important to remember that all required environment variables needs to be passed in.
