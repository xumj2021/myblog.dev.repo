#!/usr/bin/env sh

cd C:\\Users\\user\\Documents\\Testcode\\testblog\\myblog.dev.repo
hugo -D
xcopy C:\\Users\\user\\Documents\\Testcode\\testblog\\myblog.dev.repo\\public\\ C:\\Users\\user\\Documents\\Testcode\\testblog\\xumj2021.github.io\\ /h /i /c /k /e /r /y
cd ../xumj2021.github.io

msg="rebuilding site $(date)"
if [ -n "$*" ]; then
	msg="$*"
fi

git add --all
git commit -m "$msg"
git push -u origin main
