"""
CommitLinker.py

this script will grab the commits for a given github repository and output
them as a list of markdown links to each of those commits on github.
"""

import git
import argparse

def main():
    # parse the arguments for this script
    parser = argparse.ArgumentParser(description='generate a list of markdown-linked commit SHAs for a github repository.')
    parser.add_argument('path', help='the path to the local repository')
    parser.add_argument('username', help='the github username that owns this repository')
    parser.add_argument('reponame', help='the github repository name')

    args = parser.parse_args()

    path = args.path
    username = args.username
    reponame = args.reponame

    # grab the local repository based on the given path
    repo = git.Repo(path)

    # grab the commits for the repository
    commits = [commit for commit in repo.iter_commits()]

    # build the partial repository URL
    repo_url = 'https://github.com/%s/%s/commit/' % (username,reponame)

    # go through the commits and print out the markdown links for each
    for commit in commits:
        print('[%s](%s%s)' % (commit.hexsha,repo_url,commit.hexsha))

if __name__ == '__main__':
    main()
