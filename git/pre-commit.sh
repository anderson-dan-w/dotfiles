#!/bin/bash

set -e
set -o pipefail

autoflake --quiet -rc -i src/
black --check src/
isort --check src/
mypy src/
terraform fmt -recursive -check
