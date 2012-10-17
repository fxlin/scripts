SRC=$(wildcard *.c)
OBJ=$(patsubst %.c,%.arm,$(SRC))
CC=arm-linux-gnueabi-gcc

all: $(OBJ)

clean:
	rm -f *.arm

install:
	adb push $(OBJ) /data/local/

%.arm: %.c
	$(CC) -static $^ -o $@

