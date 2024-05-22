#!/bin/bash

set -euCo pipefail

# constants
readonly ORGANIZATION="baleen-studio"

function list_repo() {
  local -r query='query($endCursor: String) {
    organization(login: "'"${ORGANIZATION}"'") {
      repositories(first: 100, after: $endCursor) {
        pageInfo {
          endCursor
          hasNextPage
        }
        nodes {
          name
          isArchived
        }
      }
    }
  }'
  local -r result=$(gh api graphql -F query="$query" --paginate)
  echo "${result}" |
    jq -r '.data.organization.repositories.nodes[] | .name + " " + (.isArchived | tostring)' |
    sort
}

function main() {
  echo "| Name | URL | Description | Archived |"
  echo "| ---- | --- | ----------- | -------- |"

  while read -r line; do
    read -r name archived <<<"${line}"
    if [[ "${archived}" == "true" ]]; then
      archived="o"
    else
      archived=""
    fi
    echo "| ${name} | https://github.com/${ORGANIZATION}/${name} | | ${archived} |"
    echo "hogehoge ${line}"
  done < <(list_repo)
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  main
fi