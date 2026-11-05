#!/bin/sh

git filter-branch --env-filter '

OLD_EMAIL="cian@cianmontgomery.com"
OLD_EMAIL2="cian@cixce.com"
OLD_EMAIL="cian.montgomery@intel.com"
CORRECT_NAME="Cian Montgomery"
CORRECT_EMAIL="cian.montgomery@intel.com"

if [ "$GIT_COMMITTER_EMAIL" = "$OLD_EMAIL" ]
then
    export GIT_COMMITTER_NAME="$CORRECT_NAME"
    export GIT_COMMITTER_EMAIL="$CORRECT_EMAIL"
fi
if [ "$GIT_AUTHOR_EMAIL" = "$OLD_EMAIL" ]
then
    export GIT_AUTHOR_NAME="$CORRECT_NAME"
    export GIT_AUTHOR_EMAIL="$CORRECT_EMAIL"
fi
' --tag-name-filter cat -- --branches --tags