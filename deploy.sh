#!/bin/bash
set -ev
bundle exec ruby build.rb

remote_repo=`git remote get-url origin`
remote_branch="gh-pages"

cd ./dist
git init
git add .
git commit -m "build - `date`"
git push --force --quiet $remote_repo master:$remote_branch > /dev/null 2>&1
rm -fr .git
cd ../
