compile:
	@find src  -name '*.coffee' | xargs coffee -c
	@find demo -name '*.coffee' | xargs coffee -c

test:
	./node_modules/.bin/mocha --compilers coffee:coffee-script -R spec

.PHONY: test
