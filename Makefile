DOMAIN ?= home.pebkac.lan

COUNTRY := GR
STATE := Internet
COMPANY := P3BK4C
UNIT := NetOps

all: $(DOMAIN).csr $(DOMAIN).crt

# create the private key of root CA
rootCA.key:
	openssl genrsa -out rootCA.key 4096

# create and self sign root CA certificate
rootCA.crt: rootCA.key
	echo "$(COUNTRY)\n$(STATE)\n\n$(COMPANY)\n$(UNIT)\n\n\n\n" | openssl req -x509 -new -nodes -key rootCA.key -sha256 -days 4096 -out $@

# create the private key
$(DOMAIN).key:
	openssl genrsa -out $@ 2048

# create the configuration of OpenSSL for the certificate 
$(DOMAIN).conf:
	sh mkconf.sh $(DOMAIN) >$@

# create the CSR for a SAN certificate
$(DOMAIN).csr: $(DOMAIN).key $(DOMAIN).conf
	openssl req -new -sha256 -key $(DOMAIN).key -subj "/C=$(COUNTRY)/ST=$(STATE)/O=$(COMPANY)/OU=$(UNIT)/CN=$(DOMAIN)" \
		-reqexts SAN \
		-config $(DOMAIN).conf \
		-out $@

# verify .csr content
.PHONY: verify-csr
verify-csr:
	openssl req  -in $(DOMAIN).csr -noout -text

$(DOMAIN).san.conf:
	sh mksan.sh $(DOMAIN) $(COUNTRY) $(STATE) "$(COMPANY)" >$@

$(DOMAIN).crt: rootCA.key rootCA.crt $(DOMAIN).csr $(DOMAIN).san.conf
	openssl x509 -req -in $(DOMAIN).csr -CA ./rootCA.crt -CAkey ./rootCA.key \
		-CAcreateserial -out $@ -days 2048 -sha256 \
		-extfile $(DOMAIN).san.conf -extensions req_ext

# verify the certificate
.PHONY: verify-crt
verify-crt:
	openssl x509 -in $(DOMAIN).crt -text -noout

# remove the certificate
.PHONY: clean
clean:
	-rm -f $(DOMAIN).key $(DOMAIN).csr $(DOMAIN).conf $(DOMAIN).san.conf $(DOMAIN).crt
