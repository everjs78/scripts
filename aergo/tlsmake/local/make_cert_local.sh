#!/bin/sh
rm *.crt *.csr

openssl genrsa -out mykey.pem 2048
openssl req -new -key mykey.pem -out local.csr -config local.cnf
openssl req -noout -text -in local.csr
openssl x509 -req -in ./local.csr -CA ../root/rootca.crt -CAkey ../root/rootca.key -CAcreateserial -out local.crt -days 1000 -sha256 -extfile local.cnf  -extensions req_ext
rm ./server.crt; cat ./local*.crt > ./server.crt; cat ../root/rootca.crt >> ./server.crt
cp ./mykey.pem ./server.key
cp -rf ./server* ~/go/src/github.com/httptest/
openssl x509 -text -in local.crt
