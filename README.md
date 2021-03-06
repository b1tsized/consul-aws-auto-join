# Consul AWS Auto-Join Terraform

This repo is designed to deploy a Consul datacenter quickly into AWS and have the Consul Agents automatically join the datacenter. All the previous examples seem to be out of date using older Ubuntu instances or Terraform that is no longer valid.

 You can update the number of servers or clients by changing the values within the variables folder. This can be used as a semi-template to adapt for other cloud auto-joins listed in [Hashicorp's Docs](https://www.consul.io/docs/install/cloud-auto-join).

## Things to update

1. You'll need to update some values within the [variables.tf](variables.tf).


Update the `required-tags` section with the and other KV pairs you'd like to have on the resources. Leave `consul_join` values as is.

```HCL

variable "required-tags" {
  type = map(string)
  default = {
    Terraform  = "true"
    consul_join = "true"
  }
}

```

Update the `consul-sg-ingress-rules` with the proper `cidr_block` for your VPC CIDRs and for your personal IP to be able to access the UI on port `8500`.

```HCL

variable "consul-sg-ingress-rules" {

  type = list(object({

    from_port   = number
    to_port     = number
    protocol    = string
    cidr_block  = string
    description = string

  })) ...

```

2. Create a `terraform.tfvars` file inside this folder and add the values to all the following fields. Descriptions can be found in [variables.tf](variables.tf)

```HCL

vpc-id = ""
key-name = ""
region = ""
data-center = ""

```

## Instructions

After completing the section above. You can now do the following steps.

1. `terraform init` in the directory this repo is saved.

2. `terraform plan` to validate all changes and no errors.

3. `terraform apply --auto-approve`

4. Wait for changes to finish applying

5. Select an ip of one of the consul Servers (not clients) and connect on port `8500`.

    * E.G. `http://24.153.54.123:8500/`

6. You should now be connected to the Consul UI.