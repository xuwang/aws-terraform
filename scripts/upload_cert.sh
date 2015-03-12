# private key needs to be converted
# e.g.  openssl rsa -inform PEM -in docker_registry.pem > docker_registry.key
# Chain file needs to be in reverse order. root cert at the top (the 3rd file)
# To get arn: aws --profile anchorage iam get-server-certificate --server-certificate-name=docker-registry.example.com

# Load both dockerhub.example.com and docker-registry.example.com ssl to AWS
#aws --profile anchorage iam upload-server-certificate --server-certificate-name docker-registry.example.com --certificate-body file://docker-registry.example.com_cert.cer --private-key file://docker_registry.key --certificate-chain file://docker-registry.example.com_interm.cer
#aws --profile anchorage iam upload-server-certificate --server-certificate-name dockerhub.example.com --certificate-body file://docker-registry.example.com_cert.cer --private-key file://docker_registry.key --certificate-chain file://docker-registry.example.com_interm.cer


# Load emergency-test
aws --profile idg-dev iam upload-server-certificate --server-certificate-name emergency-test.example.com --certificate-body file://emergency-test.example.com_cert.cer --private-key file://emergency-test.key --certificate-chain file://emergency-test.example.com_interm.cer
