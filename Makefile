default:: build

curdir := $(patsubst %/,%,$(dir $(abspath $(lastword $(MAKEFILE_LIST)))))
port := 5001

.PHONY: run build clean

deps:
	git clone git@github.com:franceme/structurexe
	cd structurexe/ && python3 main.py --build
	yes|rm -r structurexe

run:
	bal run $(curdir)/

build:
	bal build $(curdir)/

fclean:
	-bal clean $(curdir)/
	-yes|rm -r ~/.ballerina/repositories/central.ballerina.io/bala/ballerina/*
	-yes|rm -r ~/.ballerina/repositories/central.ballerina.io/cache-2201.7.1/ballerina/*
	-yes|rm -r ~/.ballerina/repositories/central.ballerina.io/bala/frantzme/*
	-yes|rm -r ~/.ballerina/repositories/central.ballerina.io/cache-2201.7.1/frantzme/*

fbuild: fclean build

rbuild:
	-@make fclean
	-rm $(curdir)/Dependencies.toml
	-@make build

runbuild: rbuild
	-@make run

clean:
	-rm browser.log && touch browser.log && chmod 777 browser.log
	-rm originallog.*
	-rm *.csv
	-rm *.py.py
	-rm *.nosj.py
	-bal clean $(curdir)/