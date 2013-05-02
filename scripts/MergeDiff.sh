#!/bin/sh

# this script will go through a list of sha1 commit ids and for each it will
# print out the diff between that commit and it's parent, listing the files
# that are involved in that diff and echoing it to the console.

# this script will read in a text file that contains the path to a git
# repository on the first line and all subsequent lines are commit SHAs
# (either short or long form) that represent merge's in the given
# repository. This script will then output the diffs (in the form of file
# lists) of those merge's against each of their parents along with counts
# of the number of files involved in those diffs. This will all be output in
# a YAML format that can be saved to a file.

file=$1

repo=''
shas=[]

count=0
while read line
do
    if [ "$count" = 0 ]
    then
        repo=$line
    else
        index=$(($count - 1))
        shas[$index]=$line
    fi
    count=$(($count+1))
done < $file

# jump to the given repository
cd $repo

# go through each merge SHA and diff it with its parents
for sha in ${shas[*]};
do
    # grab the parent SHAs
    parent1=$(git rev-parse $sha\^1 2>/dev/null)
    parent2=$(git rev-parse $sha\^2 2>/dev/null)

    # echo some YAML with the following items for each merge SHA
    # - declare the diff of the first parent pairing
    # - get the file count for that first pairing
    # - list the actual files at that diff
    # - declare the diff of the second parent pairing
    # - get the file count for that second pairing
    # - list the actual files at that diff
    echo "---"
    echo "diff1: \"$sha against $parent1\""
    echo "count1: $(git diff $parent2 $sha --name-only 2>/dev/null | wc -l | tr -d ' ')"
    for item in $(git diff $parent2 $sha --name-only 2>/dev/null)
    do
        echo "- \"$item\""
    done
    echo "diff2: \"$sha against $parent2\""
    echo "count2: $(git diff $parent1 $sha --name-only 2>/dev/null | wc -l | tr -d ' ')"
    for item in $(git diff $parent1 $sha --name-only 2>/dev/null)
    do
        echo "- \"$item\""
    done
    echo "..."
done
