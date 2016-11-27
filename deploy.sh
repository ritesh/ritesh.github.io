#!/bin/bash

echo -e "\033[0;32mDeploying updates to GitHub...\033[0m"
git subtree add --prefix=public git@github.com:ritesh/ritesh.github.io.git master --squash
hugo 

# Commit changes.
msg="rebuilding site `date`"
if [ $# -eq 1 ]
  then msg="$1"
fi

git add -A
git commit -m "$msg"

# Push source and build repos.
# git push origin master

# Come Back
cd ..
echo -e "\033[0;32mPushing subtree containing blog posts...\033[0m"
git subtree push --prefix=public git@github.com:ritesh/ritesh.github.io.git master
