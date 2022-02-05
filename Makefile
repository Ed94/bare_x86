
16bit.loader: 16bit.boot 16bit.ftable 16bit.scratch
	cat 16bit.boot 16bit.ftable 16bit.scratch > 16bit.loader
	make clean

16bit.boot:
	nasm 16bit.boot.s

16bit.ftable:
	nasm 16bit.ftable.s

16bit.scratch:
	nasm 16bit.scratch.s

clean:
	rm 16bit.boot
	rm 16bit.ftable
	rm 16bit.scratch
