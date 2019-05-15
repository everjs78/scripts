openssl genrsa -out rootca.key 4096
openssl req -new -key rootca.key -out rootca.csr -config rootca.conf
openssl x509 -req \
			-sha256 \
			-days 3650 \
			-extensions v3_ca \
			-set_serial 1 \
			-in ./rootca.csr \
			-signkey ./rootca.key \
			-out rootca.crt \
			-extfile rootca.conf
