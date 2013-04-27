"""
branching.py

this module provides functionality for dealing with and understanding
branching that occurs in a git repository.
"""

import sys
import git

def main(args):
    if not args:
        print('Error: no repository path given.')
        sys.exit(1)
    print(args[0])

def find_common_parent(merge_commit):
    """
    find_common_parent

    given a merge commit object, this function will grab the two parents of
    that merge commit and find a common parent for them -- the commit at
    which the line of work originally branched into two lines of work. That
    common parent commit object will be returned.
    """
    # if the given commit isn't a merge commit -- only has 1 parent -- then
    # return the parent of the given commit
    if len(merge_commit.parents) == 1:
        return merge_commit.parents[0]

    # start by grabbing each of the parents
    parentA = merge_commit.parents[0]
    parentB = merge_commit.parents[1]

    # as long as you haven't found matching parents, keep searching
    while parentA != parentB:
        # compare committed dates, the larger date updates themself
        if parentA.committed_date > parentB.committed_date:
            # if parentA doesn't have a parent, this is a stray branch and
            # we should return from the method with the None type
            if len(parentA.parents) == 0:
                print('Encountered stray ending at branch (' + parentA.hexsha + ')')
                return None
            # just naively follow the first parent, even if there are more
            parentA = parentA.parents[0]
        else:
            # if parentB doesn't have a parent, this is a stray branch and
            # we should return from the method with the None type
            if len(parentB.parents) == 0:
                print('Encountered stray ending at branch (' + parentB.hexsha + ')')
                return None
            # just naively follow the first parent, even if there are more
            parentB = parentB.parents[0]

    return parentA

if __name__ == "__main__":
    main(sys.argv[1:])
