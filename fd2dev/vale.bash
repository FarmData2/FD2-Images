cd /var/tmp

ARCH=$(dpkg --print-architecture)
VER="3.9.2"

if [ "$ARCH" = "arm64" ]; then
    VALE_FILE=vale_"$VER"_Linux_arm64.tar.gz
else
    VALE_FILE=vale_"$VER"_Linux_64-bit.tar.gz 
fi

wget https://github.com/errata-ai/vale/releases/download/v"$VER"/"$VALE_FILE"
mkdir "vale"
tar -xvzf "$VALE_FILE" -C vale
cp vale/vale /usr/local/bin
rm "$VALE_FILE"
rm -rf vale