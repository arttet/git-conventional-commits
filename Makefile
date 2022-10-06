
################################################################################

.PHONY: help
help:	## Show this help
	@fgrep -h "## " $(MAKEFILE_LIST) | fgrep -v fgrep | sed -e 's/\\$$//' | sed -e 's/##//'

.PHONY: build
build:	## Compile the current package and all of its dependencies with timings
	cargo build --timings

.PHONY: cover
cover:	##  Build code coverage
	RUSTFLAGS="-C instrument-coverage" LLVM_PROFILE_FILE="target/coverage-%p-%m.profraw" cargo run -- .git/COMMIT_EDITMSG
	RUSTFLAGS="-C instrument-coverage" LLVM_PROFILE_FILE="target/coverage-%p-%m.profraw" cargo test
	grcov . --binary-path ./target/debug/ -s . -t html --branch --ignore-not-existing --ignore "*cargo*" -o ./target/coverage/
	grcov . --binary-path ./target/debug/ -s . -t lcov --branch --ignore-not-existing --ignore "*cargo*" -o ./target/coverage.lcov

.PHONY: clean
clean:	## Remove generated artifacts
	find . -name "*.profraw" -type f -delete
	find . -name "*.profdata" -type f -delete

################################################################################
