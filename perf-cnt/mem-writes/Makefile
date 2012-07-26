SRC=$(wildcard *.c)
OBJ=$(patsubst %.c,%.arm,$(SRC))
CC=arm-linux-gnueabi-gcc

all: $(OBJ)

clean:
	rm -f *.arm

install:
	find -name "*.arm" -exec adb push "{}" /data/local/ \;

%.arm: %.c
	$(CC) -static $^ -o $@

