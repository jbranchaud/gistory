# CommitLinker.rb
#
# this script uses grit (https://github.com/mojombo/grit) to grab the
# commits for a given local repository. It then generates markdown links for
# those commits with the given GitHub username and repository name.

require 'grit'

# main
#
# this function is only invoked if this script is being invoked directly.
# It is given the command-line arguments which should be made up of 3
# things:
# - local repository path
# - GitHub username for repository owner
# - GitHub repository name
def main(args)

  # check that 3 arguments have been given, otherwise exit
  if ARGV.length < 3
    puts "You haven't given enough arguments."
    exit
  end

  # the first argument should be the path to the local repository
  repo_path = ARGV[0]

  # the second argument should be the relevant GitHub username
  username = ARGV[1]

  # the third argument should be the repository name on GitHub
  repo_name = ARGV[2]

  # invoke link_commits with the arguments
  link_commits(repo_path, username, repo_name).each { |link| puts link }
end

# get_all_commits
#
# given a Grit::Repo object, this function will build a list of all commits
# in the repository and return that list. This is a convenience method to
# abstract away the pagination of the repo.commits function.
def get_all_commits(repo)
  all_commits = []
  page = 0
  page_size = 10
  commits = repo.commits('master', page_size, page)
  while commits.length > 0
    all_commits = all_commits + commits
    page = page + page_size
    commits = repo.commits('master', page_size, page)
  end
  return all_commits
end

# link_commits
#
# given the path to a local git repository, a GitHub username for the
# repository owner, and the name of the GitHub repository, this function
# will build a list of markdown links to each commit SHA and return that
# list.
def link_commits(repo_path, username, repo_name)

  # create a partial repo URL for GitHub repository
  partial_URL = "https://github.com/#{username}/#{repo_name}/commit/"
  
  # access the repository at the given repo_path
  repo = Grit::Repo.new(repo_path)
  
  all_commits = get_all_commits(repo)
  
  #all_commits.each{ |commit|
  #  puts "[#{commit.sha}](#{partial_URL + commit.sha})\n\n"
  #}

  return all_commits.map do |commit|
    "[#{commit.sha}](#{partial_URL + commit.sha})\n\n"
  end
end

# if this is being invoked as a script, invoke the main method
if __FILE__==$0
  main(ARGV)
end
