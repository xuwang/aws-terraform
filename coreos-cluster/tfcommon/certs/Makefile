CWD := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))
CA_CERT := $(CWD)/rootCA.pem
ETCD_CERT := $(CWD)/etcd.pem
SITE_CERT := $(CWD)/site.pem
DHPARAM := $(CWD)/dhparam.pem

all: | $(CA_CERT) $(ETCD_CERT) $(SITE_CERT)

clean:
	rm -f *.pem *.csr *.srl *.key *.crt

ca: | $(CA_CERT)

site: | $(SITE_CERT)

etcd: | $(ETCD_CERT)

$(CA_CERT): 
	echo "creating rootCA-key.pem and rootCA.pem ..."
	openssl req -x509 -new -nodes -days 9999 -config rootCA.cnf -out rootCA.pem
	chmod 600 *.pem

$(ETCD_CERT): | $(CA_CERT)
	echo "creating the etcd-key.pem and etcd.csr...."
	openssl req -new -out etcd.csr -config etcd.cnf
	echo "creating the etcd-client-key.pem and etcd-client.csr...."
	openssl req -new -out etcd-client.csr -config etcd-client.cnf
	echo "signing etcd.csr..."
	openssl x509 -req -days 9999 -in etcd.csr -CA rootCA.pem -CAkey rootCA-key.pem \
			-CAcreateserial -extensions v3_req -out etcd.pem -extfile etcd.cnf
	echo "signing etcd-client.csr..."
	openssl x509 -req -days 9999 -in etcd-client.csr -CA rootCA.pem -CAkey rootCA-key.pem \
			-CAcreateserial -extensions v3_req -out etcd-client.pem -extfile etcd-client.cnf
	echo "etcd.pem is generated:"
	openssl x509 -text -noout -in etcd.pem
	echo "etcd-client.pem is generated:"
	openssl x509 -text -noout -in etcd-client.pem
	chmod 600 *.pem

$(SITE_CERT): | $(CA_CERT)
	echo "creating the site-key.pem and site.csr...."
	openssl req -new -out site.csr -config site.cnf
	echo "signing site.csr..."
	openssl x509 -req -days 9999 -in site.csr \
		-CA rootCA.pem -CAkey rootCA-key.pem -CAcreateserial \
		-extensions v3_req -out site.pem -extfile site.cnf
	echo "site.pem is generated:"
	openssl x509 -text -noout -in site.pem
	chmod 600 *.pem

$(DHPARAM):
	#see https://raymii.org/s/tutorials/Strong_SSL_Security_On_nginx.html
	echo "generating dhparam.pem/2048 for strengthening the server security ..."
	openssl dhparam -out dhparam.pem 2048
	chmod 600 *.pem

.PHONY: all clean ca site etcd $(CA_CERT) $(ETCD_CERT) $(SITE_CERT) $(DHPARAM)
