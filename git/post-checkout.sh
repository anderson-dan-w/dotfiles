#!/usr/bin/env bash
set +e

REPO=/Users/dan/coding/dbnl-internal
pip install --quiet -r "$REPO/requirements-dev.txt"

(
  cd "$REPO/ui" && bun install --silent --frozen-lockfile
)
