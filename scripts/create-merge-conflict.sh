#!/bin/bash

echo "Initial content" > mergetest.txt
git add mergetest.txt
git commit -m "Initial commit"

git checkout -b branch1

echo "Content from branch1" > mergetest.txt
git add mergetest.txt
git commit -m "Commit on branch1"

git checkout main
git checkout -b branch2

echo "Content from branch2" > mergetest.txt
git add mergetest.txt
git commit -m "Commit on branch2"

git checkout main
git merge branch1
git merge branch2

# End of script: you are still on the main branch with a merge conflict
echo "A merge conflict has been created in 'mergetest.txt'. Resolve the conflict and then commit the result."
