getcurpos:
	gcc -Wall getcurpos.c -o getcurpos -lX11

plum.conf: plum
	sed -n '/__DATA__/,$$p' plum|sed 1d > plum.conf

