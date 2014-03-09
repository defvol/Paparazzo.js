install: compile
	npm install

compile:
	@find src  -name '*.coffee' | xargs coffee -c
	@find demo -name '*.coffee' | xargs coffee -c

run: install
	open demo/demo.html
	node demo/bootstrap.js

test:
	./node_modules/.bin/mocha --compilers coffee:coffee-script -R spec

.PHONY: test
