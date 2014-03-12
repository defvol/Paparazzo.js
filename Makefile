install:
	npm install

compile:
	@find src  -name '*.coffee' | xargs node_modules/coffee-script/bin/coffee -c
	@find demo -name '*.coffee' | xargs node_modules/coffee-script/bin/coffee -c

run: install compile
	open demo/demo.html
	node demo/bootstrap.js

test:
	./node_modules/.bin/mocha --compilers coffee:coffee-script -R spec

.PHONY: test run
