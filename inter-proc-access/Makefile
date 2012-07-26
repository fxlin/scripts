SRC=$(wildcard *.c)
OBJ=$(patsubst %.c,%.arm,$(SRC))
LIBS=-lpthread -lrt

CC=arm-linux-gnueabi-gcc
#CC=cc
#CFLAGS=-O2

# app specific

all: $(OBJ)

clean:
	rm -f *.arm

install:
	find -name "*.arm" -exec adb push "{}" /data/local/ \;

%.arm: %.c
	$(CC) -static $^ $(LIBS) $(CFLAGS) -o $@

