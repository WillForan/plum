getcurpos:
	gcc -Wall getcurpos.c -o getcurpos -lX11

test:
	find t -iname '*.t'|xargs -n1 perl
