PASSWORD="PASSWORD"
NAME="CRTLabs"

CERTS=./priv/certs/root

# Make the config Client specific
cat ./priv/certs/openssl.conf > ./priv/certs/use.conf
echo "CN=$NAME" >> ./priv/certs/use.conf

# Create the necessary files
mkdir -p $CERTS/keys $CERTS/requests $CERTS/certs $CERTS/crl
touch $CERTS/database.txt
echo 01 > $CERTS/serial.txt

# Generate your CA key (Use appropriate bit size here for your situation)
openssl genrsa -aes256 -out $CERTS/keys/ca.key -passout pass:$PASSWORD 2048

# Generate your CA req
openssl req -config ./priv/certs/use.conf -new -key $CERTS/keys/ca.key -out $CERTS/requests/ca.req -passin pass:$PASSWORD

# Make your self-signed CA certificate
openssl ca  -config ./priv/certs/use.conf -selfsign -keyfile $CERTS/keys/ca.key -out $CERTS/certs/ca.crt -in $CERTS/requests/ca.req -extensions v3_ca -passin pass:$PASSWORD -batch

rm ./priv/certs/use.conf
