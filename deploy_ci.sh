#!/bin/bash

echo -e "\033[0;32mDeploying updates to GitHub...\033[0m"
git remote add -f public git@github.com:ritesh/ritesh.github.io.git

git merge -s ours --no-commit public/master
git read-tree --prefix=public/ -u public/master

hugo 

# Commit changes.
msg="rebuilding site `date`"
if [ $# -eq 1 ]
  then msg="$1"
fi

echo -e "\033[0;32mPushing subtree containing blog posts...\033[0m"
git commit -m $msg
git subtree push --prefix public public public/master
