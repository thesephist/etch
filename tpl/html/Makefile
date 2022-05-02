all: watch

# build app
build:
	oak build --entry app.js.oak --output js/bundle.js --web
b: build

# build whenever Oak sources change
watch:
	ls *.oak | entr -cr make build
w: watch

# format changed Oak source
fmt:
	oak fmt --changes --fix
f: fmt

