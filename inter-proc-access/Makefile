SRC=$(wildcard *.c)
OBJ=$(patsubst %.c,%.arm,$(SRC))
CC=arm-linux-gnueabi-gcc
LIBS=-lpthread -lrt

# app specific


all: $(OBJ)

clean:
	rm -f *.arm

install:
	find -name "*.arm" -exec adb push "{}" /data/local/ \;

%.arm: %.c
	$(CC) -static $^ $(LIBS) -o $@

