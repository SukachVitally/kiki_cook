#!/usr/bin/env bats

@test "pypi-server exist" {
  run which pypi-server --version
  [ "$status" -eq 0 ]
}
