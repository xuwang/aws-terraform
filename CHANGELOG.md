## v0.2.0

DESIGN CHANGE:

In previous implementation, we use one build directory for all resources, so there is only one __terraform.tfstate__ file to maintain.

For more complicated cases, ongoing modifications to the infrastructure, e.g., a small change such as a security group rule, could take long time because all resources need to be refreshed and checked for consistency.

In this release, each resource has its owner __terraform/\<resource\>__ and coresponding __build/\<resource\>__ directory, so it can
be invidually managed, for example, `make <resource_only>` target will only plan and appply changes for that resource, without checking vpc dependency, if you are sure there is no vpc changes. This will speed up operations. 

This release is backwards incompatible because of the structure change. You will need to migrate to this structure.

FEATURES:

 * **envs.sh:** the file is used to override default environment variable values in **Makefile**. See [envs.sh.sample](https://github.com/xuwang/aws-terraform/blob/master/envs.sh.sample).
 * **lock, unlock:** these targets can be used in a team workflow to make sure only the person who owns the lock can alter the infrastructure. An pair of AWS key is used to facilitate the lock. 
 * **session start, session end:** same as _lock_, _unlock_, these targets force git pull and git push to keep repository in-sync if you use git to maintain terraform status and code.  
 * **etcd cluster:** the default cluster contains 1 etcd node, 1 worker node, t2.miro instance type. Change these in __terraform/etcd/etcd.tf__ or __terraform/worker/worker.tf__ for different configurations. The etcd cluster is in autoscaling group and can self-discover IP changes.
 * **graph** _make graph_ target will generate dependency graph in png format, under build/<resource> directory. See [graph-examples](https://github.com/xuwang/aws-terraform/tree/master/graph-examples) for examples. 
 * **two stage bootstraping:** all instances use the same [_user-data_](https://github.com/xuwang/aws-terraform/blob/master/resources/cloud-config/s3-cloudconfig-bootstrap.sh) file, a bootstrap script that will download the instance's specific
cloud-config file from their corresponding S3 bucket, then CoreOS will run cloud-config using the downloaed cloud-config yaml file. This means that you rarely need to tear down and rebuild machine if the only change is in the cloud-config.yaml: reboot the instance will pick up the change. 
 * **applicaiton bootstraping:** a git-sync timer unit is provisioned by cloud-config to download application relocated code, such as post-boot provisionning, account
creation, file system mount, docker units files etc. The content of the applicaiton repo is cloned under/var/lib/apps location. The timer runs every minute, to pick up new changes.  A [default app repo](https://github.com/dockerage/coreos-cluster-apps) is provided, and you can change it in __envs.sh__ to use your own repoistory. You can also configure a private key for git-sync to use for the sync.
 * **route53, iam server certificate**: these are optional resources. If you define APP_DOMAIN in envs.sh, the domain name will be used as a default route53 zone and a self-signed star server certificate will be generated and can used as default elb certitificate.
 * **default VPC**: If you change AWS region, you need to go through __terraform/vpc__ directory to make sure availablity zones are set correctly for the region,otherwise, the build will fail.
 * **technical details**: See [Technical notes](https://github.com/xuwang/aws-terraform#technical-notes).

## v0.1.0

Initial release.
