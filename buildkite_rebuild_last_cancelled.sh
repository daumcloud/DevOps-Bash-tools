#!/usr/bin/env bash
#  vim:ts=4:sts=4:sw=4:et
#
#  Author: Hari Sekhon
#  Date: 2020-04-01 18:59:00 +0100 (Wed, 01 Apr 2020)
#
#  https://github.com/harisekhon/bash-tools
#
#  License: see accompanying Hari Sekhon LICENSE file
#
#  If you're using my code you're welcome to connect with me on LinkedIn and optionally send me feedback to help steer this or other code I publish
#
#  https://www.linkedin.com/in/harisekhon
#

# Rebuilds the last cancelled build for each pipeline in BuildKite via its API (after clearing a backlog due to offline agents by cancelling all scheduled builds)
#
# https://buildkite.com/docs/apis/rest-api/builds
#
# May fail with Forbidden if your trial account has expired

set -euo pipefail
[ -n "${DEBUG:-}" ] && set -x
srcdir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# shellcheck disable=SC1090
. "$srcdir/lib/utils.sh"

# used by usage() in lib/utils.sh
# shellcheck disable=SC2034
usage_description="Rebuilds the last cancelled build for each pipeline in BuildKite via its API (after clearing a backlog due to offline agents by cancelling all scheduled builds)"
# shellcheck disable=SC2034
usage_args="[<curl_options>]"

BUILDKITE_ORGANIZATION="${BUILDKITE_ORGANIZATION:-${BUILDKITE_USER:-}}"

if [ -z "${BUILDKITE_ORGANIZATION:-}" ]; then
    usage "\$BUILDKITE_ORGANIZATION not defined"
fi

"$srcdir/buildkite_api.sh" "organizations/$BUILDKITE_ORGANIZATION/pipelines" "$@" |
jq -r '.[].slug' |
while read -r pipeline; do
    "$srcdir/buildkite_api.sh" "organizations/$BUILDKITE_ORGANIZATION/pipelines/$pipeline/builds?state=canceled" "$@" |
    jq -r 'limit(1; .[] | [.pipeline.slug, .number, .url] | @tsv)' |
    while read -r name number url; do
        url="${url#https://api.buildkite.com/v2/}"
        echo -n "Rebuilding $name build number $number:  "
        "$srcdir/buildkite_api.sh" "$url/rebuild" -X PUT |
        jq
    done
done
