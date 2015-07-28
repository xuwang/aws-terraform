To build:

    terraform plan \
        --var-file=../tfcommon/key.tfvars \
        --var-file=../tfcommon/vpc.tfvars \
        --var-file=../tfcommon/route53.tfvars
        
    terraform apply \
        --var-file=../tfcommon/key.tfvars \
        --var-file=../tfcommon/vpc.tfvars \
        --var-file=../tfcommon/route53.tfvars
