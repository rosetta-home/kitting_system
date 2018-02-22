PASSWORD="PASSWORD"
NAME="cicada"
COMMON_NAME=$1

CERTS=./priv/certs/root

# Make the config Client specific
cat ./priv/certs/openssl.conf > ./priv/certs/use.conf
echo "CN=$NAME" >> ./priv/certs/use.conf

openssl req -new -nodes -extensions client -out "$CERTS/requests/$NAME.req" -keyout "$CERTS/keys/$NAME.key" -config ./priv/certs/use.conf -passin pass:$PASSWORD -subj "/C=US/ST=IL/L=Chicago/O=CRTLabs/CN=$COMMON_NAME"
openssl ca -batch -extensions client -keyfile $CERTS/keys/ca.key -cert $CERTS/certs/ca.crt -config ./priv/certs/use.conf -out "$CERTS/certs/$NAME.crt" -passin pass:$PASSWORD -infiles "$CERTS/requests/$NAME.req"

rm ./priv/certs/use.conf
