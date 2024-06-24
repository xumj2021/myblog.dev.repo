@echo off

cd "C:\Users\user\Documents\Testcode\testblog\myblog.dev.repo"
hugo -D
xcopy "C:\Users\user\Documents\Testcode\testblog\myblog.dev.repo\public\" "C:\Users\user\Documents\Testcode\testblog\xumj2021.github.io\" /h /i /c /k /e /r /y
cd ..\xumj2021.github.io

rem Set the current date and time
for /f "tokens=2 delims==" %%i in ('wmic os get localdatetime /value') do set datetime=%%i
set msg=rebuilding site %datetime%
if "%*" neq "" (
    set msg=%*
)

git add --all
git commit -m "%msg%"
git push -u origin main
