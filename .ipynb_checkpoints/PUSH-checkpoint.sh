branch="experiment"

if [ -d ".git" ]; then
    :
else
    git init
fi

if git remote get-url origin >/dev/null 2>&1; then
    :
else
    git remote add origin "git@github.com:ASTERISC-ASU/sysemu-testing.git"
fi

git fetch origin

if git show-ref --verify --quiet "refs/heads/$branch"; then
    git switch "$branch"
else
    if git show-ref --verify --quiet "refs/remotes/origin/$branch"; then
        git switch -c "$branch" --track "origin/$branch"
    else
        git switch -c "$branch"
    fi
fi

if git show-ref --verify --quiet "refs/remotes/origin/$branch"; then
    git pull --rebase origin "$branch"
else
    :
fi

git add .

if git diff --cached --quiet; then
    :
else
    git commit -m "What I did was committing some changes!"
fi

git push -u origin "$branch"