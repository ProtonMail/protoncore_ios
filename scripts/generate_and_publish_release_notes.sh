#!/bin/bash -x

git fetch --tags --force --prune

TAGS_STRING=$(git tag --merged main | grep --regex "\d*\.\d*\.\d*.*" | sort -r -V | head -2 | sort -V | tr '\n' ' ')
TAGS_ARRAY=(`echo "$TAGS_STRING"`)

SLACK_RELEASE_NOTES_HEADER=$(echo "\n\nNew ProtonCore version available 🎉\n\n→ *${TAGS_ARRAY[1]}* ← \n\n Release notes:\n\n")
SLACK_RELEASE_NOTES_BODY=$(git log --pretty="format:* %B  (<mailto:%ae|%an>, %cs, <https://gitlab.protontech.ch/apple/shared/protoncore/-/commit/%H|%h, see it on gitlab>)%n" --no-merges ${TAGS_ARRAY[0]}..${TAGS_ARRAY[1]} | sed "s/\'/\\\'/g" | sed 's/\"/\\\"/g' )
SLACK_RELEASE_NOTES_FOOTER=$(echo "\n\nUpdate your Podfile and let us know of any issues at <#C01B9FRKWRM> channel 🚀\n\n")

SLACK_RELEASE_NOTES=$(echo "$SLACK_RELEASE_NOTES_HEADER\`\`\`\n$SLACK_RELEASE_NOTES_BODY\n\`\`\`$SLACK_RELEASE_NOTES_FOOTER")

echo "$SLACK_RELEASE_NOTES"

curl -X POST -H 'Content-type: application/json' --data "{\"text\":\"$SLACK_RELEASE_NOTES\"}" $SLACK_RELEASE_NOTES_WEBHOOK_URL

FILE_RELEASE_NOTES_BODY=$(git log --pretty="format:* %s %b  %n  ([%an](mailto:%ae), %cs, [%h, see it on gitlab](https://gitlab.protontech.ch/apple/shared/protoncore/-/commit/%H))%n" --no-merges ${TAGS_ARRAY[0]}..${TAGS_ARRAY[1]})
FILE_RELEASE_NOTES="# ${TAGS_ARRAY[1]}

## Release notes for ProtonCore version ${TAGS_ARRAY[1]}:

$FILE_RELEASE_NOTES_BODY"

echo "$FILE_RELEASE_NOTES" > ReleaseNotes.md