@echo off
setlocal enabledelayedexpansion

set "branch=experiment"

if not exist ".git" (
    git init
)

git remote get-url origin >nul 2>&1

if errorlevel 1 (
    git remote add origin git@github.com:ASTERISC-ASU/sysemu-testing.git
)

git fetch origin

git show-ref --verify --quiet refs/heads/%branch%

if %errorlevel%==0 (
    git switch %branch%
) else (
    git show-ref --verify --quiet refs/remotes/origin/%branch%
    if %errorlevel%==0 (
        git switch -c %branch% --track origin/%branch%
    ) else (
        git switch -c %branch%
    )
)

git show-ref --verify --quiet refs/remotes/origin/%branch%

if %errorlevel%==0 (
    git pull --rebase origin %branch%
)

git add .
git diff --cached --quiet

if not %errorlevel%==0 (
    git commit -m "What I did was committing some changes!"
)

git push -u origin %branch%

endlocal