#!/bin/bash
set -e

#if keyword is found
if [ -n "$GITHUB_EVENT_PATH"];
then
  EVENT_PATH=$GITHUB_EVENT_PATH
elif [ -f ./sampledata.json];
then 
  EVENT_PATH='./sampledata.json'
  LOCAL_TEST=true
else
  echo "No json data found"
  exit 1
fi

env
cat . < $EVENT_PATH

if jq '.commits[].message, .head_commit.message' < $EVENT_PATH | grep -i -q "$*";
then
  VERSION=$(date +%F .%S)

  DATA="$(printf '{"tag_name":"v%s",' $VERSION})"
  DATA="${DATA} $(printf '"target_commitish":"master",')"
  DATA="${DATA} $(printf '"name":"v%s",' $VERSION)"
  DATA="${DATA} $(printf '"body":"Automated release based on keyword: %s",' "$*")"
  DATA="${DATA} $(printf '"draft":false, "prerelease": false')"

  URL= "https://api.github.com/repos/${GITHUB_REPOSITORY}/releases?access_token=${GITHUB_TOKEN}"

  if [[ "${LOCAL_TEST}" == *"true"* ]];
  then
    echo "## [TESTING] Keyword was found but no release was found."
  else
    echo $DATA | http POST $URL | jq .
  fi

else
  echo "keyword not found"
  exit 1
fi
