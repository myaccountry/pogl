static:
	fpc -Xm -Xs -B -opogl main.pas

clean:
	rm *.o *.ppu

all:
	make && make clean

