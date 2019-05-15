#!/bin/sh
rm *.crt *.csr

openssl req -new -key mykey.pem -out local.csr -config local.cnf
openssl req -noout -text -in local.csr
openssl x509 -req -in ./local.csr -CA ../root/test-rootCA.crt -CAkey ../root/test-rootCA.key -CAcreateserial -out local.crt -days 1000 -sha256 -extfile local.cnf
rm ./server.crt; cat ./local*.crt > ./server.crt; cat ../root/test-rootCA.crt >> ./server.crt
cp -rf ./server* ~/go/src/github.com/httptest/
openssl x509 -text -in local.crt
