.PHONY: generate build test check run

generate:
	./scripts/dev.sh generate
build:
	./scripts/dev.sh build
test:
	./scripts/dev.sh test
check:
	./scripts/dev.sh check
run:
	./scripts/dev.sh run
