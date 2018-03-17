# Testing

Execute `test.sh` to fetch testing dependecies and execute all tests.

## Running a single test

Inside a test dir run `../vendor/bin/current/bats .` to execute all tests in this folder.

## Test naming convention

Tests are named test - type, number - test target.

Types:
- 0xx Unit tests
- 1xx Integration tests (using mocks)
- 2xx End to end tests (chain tests)
