#!/bin/bash

echo -e "\033[0;32mDeploying updates to GitHub...\033[0m"
git subtree pull --prefix=public git@github.com:ritesh/ritesh.github.io.git master --squash
git remote add -f ritesh-github-io git@github.com:ritesh/ritesh.github.io.git master 

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
echo -e "\033[0;32mPushing subtree containing blog posts...\033[0m"
git push origin `git subtree split --prefix=public ritesh-github-io:master`:master --force
# git subtree push --prefix=public git@github.com:ritesh/ritesh.github.io.git master
