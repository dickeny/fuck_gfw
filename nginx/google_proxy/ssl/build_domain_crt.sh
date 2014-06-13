#!/bin/bash

#openssl req -new -key google.key -out google.com.csr -subj '/C=US/ST=Oregon/L=Portland/CN=*.google.com'
#openssl ca -policy policy_anything -days 1460 -cert ca.crt -keyfile ca.key -in google.com.csr -out google.com.crt
#openssl req -new -key google.key -out google.com.hk.csr -subj '/C=US/ST=Oregon/L=Portland/CN=*.google.com.hk'
#openssl ca -policy policy_anything -days 1460 -cert ca.crt -keyfile ca.key -in google.com.hk.csr -out google.com.hk.crt

domain=$1
if [ "x$domain" == "x" ]; then
    echo "$0 gmail.com.cn"
    exit 0
fi

if [ ! -f common.key ]; then
    echo "======> building common key"
    openssl genrsa -des3 -out common.pem 1024
    openssl rsa -in common.pem -out common.key
fi

if [ ! -f ca.crt ]; then
    cp common.key ca.key
    openssl req -new -x509 -days 7305 -key ca.key -out ca.crt
    openssl x509 -in ca.crt -outform DER -out ca.der
    mkdir -p CA/newcerts
    touch CA/index.txt
    touch CA/serial
    echo 01 > CA/serial
fi

openssl req -new -key common.key -out $domain.csr -subj "/C=US/ST=Oregon/L=Portland/CN=*.$domain"
openssl ca -batch -policy policy_anything -days 1460 -cert ca.crt -keyfile ca.key -in $domain.csr -out $domain.crt
rm $domain.csr

