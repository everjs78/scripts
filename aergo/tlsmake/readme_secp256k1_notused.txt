* ref
  * https://www.lesstif.com/pages/viewpage.action?pageId=6979614
  * https://gist.github.com/fntlnz/cf14feb5a46b2eda428e000157447309

* root ca key생성
  * password 없애고 싶으면 -des3제거
openssl genrsa -des3 -out test-rootCA.key 4096
openssl genrsa out test-rootCA.key 4096

* root ca용 csr 생성
`
rootca.conf
[ req ]
default_bits            = 2048
default_md              = sha1
default_keyfile         = test-rootca.key
distinguished_name      = req_distinguished_name
extensions             = v3_ca
req_extensions = v3_ca
  
[ v3_ca ]
basicConstraints       = critical, CA:TRUE, pathlen:0
subjectKeyIdentifier   = hash
##authorityKeyIdentifier = keyid:always, issuer:always
keyUsage               = keyCertSign, cRLSign
nsCertType             = sslCA, emailCA, objCA
[req_distinguished_name ]
countryName                     = Country Name (2 letter code)
countryName_default             = KR
countryName_min                 = 2
countryName_max                 = 2
 
# 회사명 입력
organizationName              = Organization Name (eg, company)
organizationName_default      = Blocko Inc.
  
# 부서 입력
#organizationalUnitName          = Organizational Unit Name (eg, section)
#organizationalUnitName_default  = Condor Project
  
# SSL 서비스할 domain 명 입력
commonName                      = Common Name (eg, your name or your server's hostname)
commonName_default             = everjs-dev-macbook's Self Signed CA
commonName_max                  = 64 
`
openssl req -new -key test-rootca.key -out test-rootca.csr -config rootca.conf


* root ca용 self certificate 생성
openssl req -x509 -new -nodes -key test-rootCA.key -sha256 -days 3024 -out rootCA.crt
openssl x509 -req \
-sha256 \
-days 3650 \
-extensions v3_ca \
-set_serial 1 \
-in ./test-rootca.csr \
-signkey ./test-rootca.key \
-out test-rootca.crt \
-extfile rootca_openssl.conf



# local certificate 생성
* local server용 키 생성 
* 여기서는 eliptic curve secp256k1(bitcoin, libp2p) 을 사용한다.
  * parameter file 생성해서 input으로 쓰는것도 가능
    * openssl ecparam -name secp256k1 -out secp256k1.pem

openssl ecparam -name secp256k1 -genkey -noout -out mykey.pem

* local csr 생성
`
[req]
default_bits = 2048
prompt = no
default_md = sha256
req_extensions = req_ext
distinguished_name = dn
 
[ dn ]
C=KR
ST=Gyeonggi-Do
L=Seongnam
O=Blocko
OU=R&D
emailAddress=sg31park@blocko.io
CN = 191.168.1.14
 
[ req_ext ]
subjectAltName = @alt_names
 
[ alt_names ]
IP.1 = 191.168.1.14
`
openssl req -new -key mykey.pem -out local.csr -config local.cnf

* csr 확인
openssl req -noout -text -in local.csr

* CA 인증 머신에서 local 인증서 발급
openssl x509 -req -in ./local.csr -CA ../root/test-rootCA.crt -CAkey ../root/test-rootCA.key -CAcreateserial -out local.crt -days 1000 -sha256 -extfile local.cnf -extensions req_ext


* 인증서 확인
openssl x509 -text -in local.crt 


* https를 위해 server인증서와 CA인증서를 묶기
rm ./server.crt; cat ./local*.crt > ./server.crt; cat ../root/test-rootCA.crt >> ./server.crt
cp -rf ./server* ~/go/src/github.com/httptest/


* curl로 https 접속하기
 curl -v "https://192.168.1.14:10100/hello" --key "./mykey.pem" --cert "./local.crt" --cacert "./test-rootca.crt" --cert-type PEM
