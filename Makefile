all: build

# build CLI
build:
	oak build.oak
	oak pack --entry src/_main.oak -o etch
b: build

# install CLI
install:
	oak build.oak
	oak pack --entry src/_main.oak -o /usr/local/bin/etch

# format changed Oak source
fmt:
	oak fmt --changes --fix
f: fmt

