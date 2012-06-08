rm -f recvfile sendfile
ln -s recvfile-$1 recvfile
ln -s sendfile-$1 sendfile
ls -l recvfile sendfile
