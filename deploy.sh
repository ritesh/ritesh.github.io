#!/bin/bash

echo -e "\033[0;32mDeploying updates to GitHub...\033[0m"

# Build the project.
hugo # if using a theme, replace by `hugo -t <yourtheme>`

# Go To Public folder
git config --global user.email "riteshkumarsinha@gmail.com"
git config --global user.name "CirceCI bot"
git remote add -f ritesh-github-io git@github.com:ritesh/ritesh.github.io.git
git fetch ritesh-github-io master
git subtree pull --prefix=public master --squash
hugo 


# Commit changes.
msg="rebuilding site `date`"
if [ $# -eq 1 ]
  then msg="$1"
fi

cd public
git add -A
git commit -m "$msg"

# Push source and build repos.
# git push origin master

# Come Back
cd ..
echo -e "\033[0;32mPushing subtree containing blog posts...\033[0m"
git subtree push --prefix=public git@github.com:ritesh/ritesh.github.io.git master
