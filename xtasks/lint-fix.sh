#!/usr/bin/env bash
#MISE alias=["format", "fix"]
#MISE wait_for=["render:settings"]
set -euxo pipefail

# Used for shellcheck which needs explicit args
scripts=("$PWD"/scripts/*.sh "$PWD"/e2e/{test_,run_}* "$PWD"/e2e/*.sh)
# Used for shfmt which will run only on files it can
scripts_dirs=("$PWD"/scripts "$PWD"/e2e)
shellcheck -x "${scripts[@]}"
shfmt -w  -i 2 -ci -bn "${scripts_dirs[@]}"
# shellcheck disable=SC2046
prettier -w $(git ls-files '*.yml' '*.yaml')
prettier -w .
markdownlint --fix .
taplo fmt
SHELLCHECK_OPTS="--exclude=SC1090 --exclude=SC2046" actionlint
toml-sort -i settings.toml --spaces-indent-inline-array 4
toml-sort -i registry.toml --spaces-indent-inline-array 4

cat >rustfmt.toml <<EOF
unstable_features = true
imports_granularity = "Module"
EOF
cargo fmt --all
rm rustfmt.toml

hk fix --all
