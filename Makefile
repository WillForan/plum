getcurpos:
	gcc -Wall getcurpos.c -o getcurpos -lX11

plumb.conf: plum
	sed -n '/__DATA__/,$$p' plum|sed 1d > plum.conf

