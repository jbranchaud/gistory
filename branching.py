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

def find_nearest_common_parent(merge_commit):
    """
    find_nearest_common_parent
    
    given a merge commit object, this function will grab its parents and
    invoke the find_all_parents with those two parents as the arguments. The
    list of commit objects returned by the find_all_parents function will
    need to be searched through to identify the commit object with the most
    recent commit date. That commit object is then returned.
    """
    # if the given commit object is not a merge, return None
    if len(merge_commit.parents) < 2:
        return None

    # call the find_all_parents function on the parents
    parents = find_all_parents(merge_commit.parents[0], merge_commit.parents[1])

    # if there are no resulting parents, then return None
    if not parents:
        return None

    # get the commit with the most recent commit date
    return max([(commit.committed_date,commit) for commit in parents])[1]

def find_all_parents(c1,c2):
    """
    find_all_parents

    given two commit objects, this function will start traversing through
    their parent chain until a common parent is found. If a merge commit is
    encountered, then this function is recursively called on each pairing of
    the merge's parents with the other commit.
    """
    # an empty list to put come parent commits in
    commits = []

    # once we have encountered the same parent, we can exit the while loop
    while c1 != c2:
        # if c1 is a merge
        if len(c1.parents) == 2:
            # a merge has been reached, so break the problem into two
            # subproblems with the find_all_parents of c2 with each of the
            # parents of the c1 merge commit.
            commits.extend(find_all_parents(c1.parents[0],c2))
            commits.extend(find_all_parents(c2.parents[1],c2))
            return commits
        elif len(c2.parents) == 2:
            # a merge has been reachced, so break the problem into two
            # subproblems with the find_all_parents of c1 with each of the
            # parents of the c2 merge commit.
            commits.extend(find_all_parents(c1,c2.parents[0]))
            commits.extend(find_all_parents(c1,c2.parents[1]))
            return commits
        else:
            # find the more recent commit and advance it to its parent
            if c1.committed_date > c2.committed_date:
                c1 = c1.parents[0]
            else:
                c2 = c2.parents[0]

    # a common parent has been reached, wrap in a list and return
    return [c1]

"""
TODO: add a function that is given a git.Repo object and will go through all
the commits in the repository to make sure that it is a reasonably valid
repository. This involves some of the following things:
- the committed date of a commit object should always be greater than the
  committed date of that commit object's parent. Make sure this is valid
  assumption even in the case of things like rebasing.
- no commit can ever have more than 2 parents
- there should only be one commit with no parents which is the root commit.
  This may not, however, be true for some repositories where two different
  commit histories get merged. Check this assumption.
- others?
This is necessary because it is possible to manual construct portions of a
git repository as well as amend/modify its history in unpredictable way. We
need to make sure the repositories that we are dealing with are predictable.
If they are predictable, then we will consider them to be reasonably valid.
"""

if __name__ == "__main__":
    main(sys.argv[1:])
