################################################################################

.PHONY: help
help:	## Show this help
	@fgrep -h "## " $(MAKEFILE_LIST) | fgrep -v fgrep | sed -e 's/\\$$//' | sed -e 's/##//'

.PHONY: build
build:	## Run cargo build
	cargo build --timings

.PHONY: test
test:	## Run cargo test
	cargo test --tests --all-features

.PHONY: check
check:	## Check Rust code
	@make .check-doc

.PHONY: cover
cover:	##  Build code coverage
	RUSTFLAGS="-C instrument-coverage" LLVM_PROFILE_FILE="target/coverage-%p-%m.profraw" cargo run -- .git/COMMIT_EDITMSG
	RUSTFLAGS="-C instrument-coverage" LLVM_PROFILE_FILE="target/coverage-%p-%m.profraw" cargo test --tests --all-features
	grcov . --binary-path ./target/debug/ -s . -t html --branch --ignore-not-existing --ignore "*cargo*" -o ./target/coverage/
	grcov . --binary-path ./target/debug/ -s . -t lcov --branch --ignore-not-existing --ignore "*cargo*" -o ./target/coverage.lcov

.PHONY: clean
clean:	## Remove generated artifacts
	find . -name "*.profraw" -type f -delete
	find . -name "*.profdata" -type f -delete

################################################################################

.PHONY: image
image:	##  Build the Docker image
	docker build . --file Dockerfile --tag git-conventional-commits:dev

################################################################################

.PHONY: .check-doc
.check-doc:
	RUSTDOCFLAGS="-D missing_docs -D rustdoc::missing_doc_code_examples" cargo doc --workspace --all-features --no-deps --document-private-items
