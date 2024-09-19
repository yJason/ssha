#!/bin/bash
currentBranch=$(git rev-parse --abbrev-ref HEAD)
sourceBranch=$currentBranch
targetBranch="test"
nopush=0

checkAndCheckout(){
    if  ! git branch | grep -qw "$1"  ; then
        if ! git branch -r | grep -qw "origin/$1" ; then
            echo "No such branch 'origin/$1' in remote and local."
            exit 1
        fi
        echo "start checkout remote branch : origin/$1"
        git checkout -b "$1" "origin/$1"
    fi
    if git log --pretty=oneline --abbrev-commit --decorate HEAD..origin/"$1" | grep -qw ".*" ; then
        git checkout "$1" && \
        git pull "$1"
    fi
}
if [ "$#" -eq 1 ] && [[ "$1" =~ ^[^-].*$ ]]; then
    targetBranch=$1
elif [ "$#" -gt 1 ]; then
    while [ "$#" -gt 0 ]; do
        case $1 in
            "-s")
                sourceBranch=$2
                shift
                shift
                ;;
            "-t")
                targetBranch=$2
                shift
                shift
                ;;
            "--no-push")
                nopush=1
                shift
                ;;
            "-h")
                echo "-s sourceBranch \n -t targetBranch\n --no-push  only merge and donot push \n"
                exit 0
                shift
                ;;
            esac
    done
fi

echo "sourceBranch : ${sourceBranch}"
echo "targetBranch : ${targetBranch}"

if [[ "$sourceBranch" == "$targetBranch" ]]; then
    echo "The target branch is the same as the source branch; abandon the merge."
    exit 1
fi

git  fetch origin --quiet
checkAndCheckout $targetBranch
checkAndCheckout $sourceBranch

git checkout "$targetBranch" && \
git pull && \
git merge --no-ff "$sourceBranch"
if [ "$?" == 0 ] && [ "$nopush" -eq 0 ]; then
    git push
fi
git checkout "$currentBranch"
