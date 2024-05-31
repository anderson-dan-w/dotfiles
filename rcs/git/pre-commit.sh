#!/bin/bash

set -e
set -o pipefail

autoflake --quiet -rc -i src/
black --check src/
isort --check src/
mypy src/

# helm chart-testing very dbnl-internal specific
ct lint --chart-dirs app/api-srv,app/worker-srv,app/migration-job,app/ui-srv/ --target-branch main 1>/dev/null

terraform fmt -recursive -check
