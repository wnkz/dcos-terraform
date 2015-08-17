# dcos-terraform
Deploy [DCOS](https://mesosphere.com/product/) on AWS with [Terraform](https://www.terraform.io/)

## Disclaimer
This project is **not** affiliated with [mesosphere.com](https://mesosphere.com/) or [terraform.io](https://www.terraform.io/) ; there is absolutely **no** guarantee whatsoever.
You are 100% responsible for what you decide to run on you computer.

The AWS resources deployed by this project are **not** free, you are the only responsible for any unplanned costs.

## What is this ?

Currently, https://github.com/wnkz/dcos-terraform/tree/master/dcos-single-master deploys DCOS 1.1 early access. I plan to add / update different version as DCOS evolves.

## Differences with CloudFormation template

This install differs a bit from what you can find at https://downloads.mesosphere.com/dcos/EarlyAccess/aws.html.

* Default instance type is `m4.xlarge` instead of `m3.xlarge`
* A 100 Go EBS volume is attached to every slave node. This is mainly because `m4` generation on AWS does not provide ephemeral disks anymore and is EBS optimized by default.

## How to use ?

Like with DCOS with CloudFormation, you will need a SSH keypair ; create one and remember its name.

##### `terraform apply`

```
terraform apply -var 'key_name=PRIVATE_KEY_NAME' -var 'aws_access_key=YOUR_ACCESS_KEY' -var 'aws_secret_key=YOUR_SECRET_KEY' -var 'admin_location=YOUR_PUBLIC_IP/32'
```

##### WARNING

If you do not specify an `admin_location` variable, access will be allowed to `0.0.0.0/0`

See https://github.com/wnkz/dcos-terraform/blob/master/dcos-single-master/variables.tf for all the variable you can change with the `-var` Terraform flag.

## Known issues

At the moment, and due to a Terraform bug with `create_before_destroy = true` (https://github.com/hashicorp/terraform/issues/2493) `terraform destroy` (and `terraform plan -destroy`) will not work as intended.

As a temporary workaround, you can do:

```bash
sed -i '' -e 's/create_before_destroy = true/create_before_destroy = false/g' dcos-single-master/*.tf
terraform destroy
sed -i '' -e 's/create_before_destroy = false/create_before_destroy = true/g' dcos-single-master/*.tf
```

## TODOs

- [] Fix `create_before_destroy` issues
- [] Support multi master HA DCOS install
- [] More customization
