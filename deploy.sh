#!/bin/sh

# If a command fails then the deploy stops
set -e

printf "\033[0;32mDeploying updates to GitHub...\033[0m\n"

# Create commit message
msg="rebuilding site $(date)"
if [ -n "$*" ]; then
	msg="$*"
fi

# Build the project.
echo ""
echo ""
echo "Committing changes to $(pwd)"
hugo -D

# Go To Public folder
cd public

# Add 'public' (Github Pages repo) changes to git and commit/push.
echo ""
echo ""
echo "Committing changes to $(pwd)"
git add .
# git commit -m "test"
git commit -m "$msg"
# git push origin master
git push https://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@github.com/xumj2021/xumj2021.github.io.git HEAD:master
# The personal access token is automatically suspended every time when publishing, need to generate new personal access
# then, see more details in https://ginnyfahs.medium.com/github-error-authentication-failed-from-command-line-3a545bfd0ca8
# Add this repos changes to git and commit/push. First 'cd' out of public
cd ..
echo ""
echo ""
echo "Committing changes to $(pwd)"
git add .
git commit -m "$msg"
# git push origin master
git push https://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@github.com/xumj2021/myblog.dev.repo.git HEAD:master

# git push https://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@github.com/xumj2021/myblog.dev.repo.git
# git push origin master
