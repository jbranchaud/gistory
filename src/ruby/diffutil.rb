# diffutil.rb
#
# This module provides a collection of methods that take advantage of the
# git repository diff functionality provided by grit.

require 'grit'

REPO_PATH="#{ENV['HOME']}/Documents/git/dragonballer"

def main()
  puts "Let's do some diffing!"

  # create the repo object
  repo = Grit::Repo.new(REPO_PATH)

  head = repo.commit('HEAD')
  previous = repo.commit('HEAD^')
  diffs = repo.diff(head, previous)

  diffs.each do |diff|
    if diff.new_file
      puts "Added: #{diff.b_path}"
    elsif diff.deleted_file
      puts "Deleted: #{diff.a_path}"
    elsif diff.renamed_file
      puts "Renamed: #{diff.a_path} -> #{diff.b_path}"
    else
      puts "Modified: #{diff.b_path}"
    end
  end
end

module DiffUtil

  # DiffUtil.summarize_diff
  #
  # given two SHAs, output a summary of the files in the diff by
  # differentiating between the added, deleted, renamed, and modified
  # files.
  def DiffUtil.summarize_diff(repo,commit1,commit2)
    diffs = repo.diff(commit1,commit2)
    
    diffs.each do |diff|
      if diff.new_file
        puts "Added: #{diff.b_path}"
      elsif diff.deleted_file
        puts "Deleted: #{diff.a_path}"
      elsif diff.renamed_file
        puts "Renamed: #{diff.a_path} -> #{diff.b_path}"
      else
        puts "Modified: #{diff.b_path}"
      end
    end
  end

  # DiffUtil.get_added_diffs
  #
  # given a repo and two SHAs, return an Array of the diff objects that are
  # associated with added files.
  def DiffUtil.get_added_diffs(repo,commit1,commit2)
    diffs = repo.diff(commit1,commit2)

    return diffs.map { |diff| diff.new_file ? diff : nil }.compact
  end

  # DiffUtil.get_deleted_diffs
  #
  # given a repo and two SHAs, return an Array of the diff objects that are
  # associated with deleted files.
  def DiffUtil.get_deleted_diffs(repo,commit1,commit2)
    diffs = repo.diff(commit1,commit2)

    return diffs.map { |diff| diff.deleted_file ? diff : nil }.compact
  end

  # DiffUtil.get_renamed_diffs
  #
  # given a repo and two SHAs, return an Array of the diff objects that are
  # associated with renamed files.
  def DiffUtil.get_renamed_diffs(repo,commit1,commit2)
    diffs = repo.diff(commit1,commit2)

    return diffs.map { |diff| diff.renamed_file ? diff : nil }.compact
  end

  # DiffUtil.get_modified_diffs
  #
  # given a repo and two SHAs, return an Array of the diff objects that are
  # associated with modified files.
  def DiffUtil.get_modified_diffs(repo,commit1,commit2)
    diffs = repo.diff(commit1,commit2)

    return diffs.map { |diff| diff.renamed_file ? nil : diff.deleted_file ? nil : diff.new_file ? nil : diff }.compact
  end

end

if __FILE__==$0
  main()
end
