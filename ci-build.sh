pwd
ls -la ~

wget -q https://go.dev/dl/go1.22.3.windows-amd64.zip
unzip -q go1.22.3.windows-amd64.zip

export PATH=$PATH:$(pwd)/go/bin
export GOROOT=$(pwd)/go

go version
git submodule init
git submodule update

cd go-algorand
./scripts/configure_dev.sh
make install

tar -czf ../node.tar.gz -C ~/go bin
