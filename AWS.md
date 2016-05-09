
# Setup AWS Credentials

Think of a name

Go to [AWS Console](https://console.aws.amazon.com/).

1. Signup AWS account if you don't already have one. The default EC2 instances created by this tool is covered by AWS Free Tier (https://aws.amazon.com/free/) service.
2. Create a group `coreos-cluster` with `AdministratorAccess` policy.
3. Create a user `coreos-cluster` and __Download__ the user credentials.
4. Add user `coreos-cluster` to group `coreos-cluster`.

# Configure AWS Profile

```
$ aws configure --profile coreos-cluster
```

Use the [downloaded aws user credentials](#setup-aws-credentials) when prompted.

The above command will create a __coreos-cluster__ profile authentication section in ~/.aws/config and ~/.aws/credentials files. The build process bellow will automatically configure Terraform AWS provider credentials using this profile. 

# [Device Naming on Linux Instances](http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/device_naming.html)


# What is an instance role profile?


# List of Amzon Regions & Availability Zones

[Regions & AZs](https://gist.github.com/neilstuartcraig/0ccefcf0887f29b7f240)


