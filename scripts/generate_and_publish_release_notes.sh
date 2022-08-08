#!/bin/bash -x

if [ $# -eq 0 ]; then
  echo "No branch name provided"
  exit
elif [ $# -ne 1 ]; then
  echo "Too many parameters provided"
  exit
fi

RELEASE_BRANCH=$1

git fetch --tags --force --prune

TAGS_STRING=$(git tag --merged $RELEASE_BRANCH | grep --regex "\d*\.\d*\.\d*.*" | sort -r -V | head -2 | sort -V | tr '\n' ' ')
TAGS_ARRAY=(`echo "$TAGS_STRING"`)

SLACK_RELEASE_NOTES_HEADER=$(echo "\n\nNew ProtonCore version available 🎉\n\n→ *${TAGS_ARRAY[1]}* ← \n\n Release notes:\n\n")
SLACK_RELEASE_NOTES_BODY=$(cat CHANGELOG.md)
SLACK_RELEASE_NOTES_FOOTER=$(echo "\n\nUpdate your Podfile and let us know of any issues at <#C01B9FRKWRM> channel 🚀\n\n")

SLACK_RELEASE_NOTES=$(echo "$SLACK_RELEASE_NOTES_HEADER\n$SLACK_RELEASE_NOTES_BODY\n$SLACK_RELEASE_NOTES_FOOTER")

echo "$SLACK_RELEASE_NOTES"

curl -X POST -H 'Content-type: application/json' --data "{\"text\": {\"type\": \"mrkdwn\", \"text\": \"$SLACK_RELEASE_NOTES\"}}" $SLACK_RELEASE_NOTES_WEBHOOK_URL 

