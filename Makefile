test:
	./node_modules/.bin/mocha --compilers coffee:coffee-script -R spec

.PHONY: test