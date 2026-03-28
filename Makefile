.PHONY: test test-unit test-structure test-evals test-all

test-unit:
	shellspec tests/spec/

test-structure:
	shellspec tests/structure/

test-evals:
	./tests/evals/eval-runner.sh

test: test-unit test-structure

test-all: test test-evals
