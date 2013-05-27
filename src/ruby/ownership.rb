#!/usr/env ruby

# ownership.rb

require File.dirname(__FILE__) + '/diffutil'
require 'grit'

TEST_REPO_PATH = '/Users/jbranchaud/Documents/research/eval-subjects/voldemort-farm/voldemort0'
TEST_REPO = Grit::Repo.new(TEST_REPO_PATH)

repo = TEST_REPO

# grab all commits on the master branch
all_commits = []
page = 0
page_size = 10
commits = repo.commits('master', page_size, page)
while commits.length > 0
  all_commits = all_commits + commits
  page = page + page_size
  commits = repo.commits('master', page_size, page)
end

all_commits.each do |commit|
  puts "[#{commit.parents.length}] #{commit.sha}"
  puts "    #{commit.author}"
end

# go through the commits, if it has 1 parent, do a diff.
# if there are 2 parents, then skip it
# if there are 0 parents, then stop
ownership_map = Hash.new
all_commits.each do |commit|
  if commit.parents.length == 1
    DiffUtil.get_all_paths(commit.parents[0],commit).each do |path_name|
      key = "#{commit.author}::#{path_name}"
      if ownership_map[key]
        ownership_map[key] += 1
      else
        ownership_map[key] = 1
      end
    end
  end
end

puts ownership_map

ownership_map.each do |key,count|
  puts "#{count} : #{key}" if count > 50
end
