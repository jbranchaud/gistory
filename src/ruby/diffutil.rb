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

    return diffs.map { |diff| diff.renamed_file ? nil :
      diff.deleted_file ? nil :
      diff.new_file ? nil :
      diff }.compact
  end

  # DiffUtil.get_all_diffs
  #
  # given a repo and two SHAs, return an Array of the diff objects
  def DiffUtil.get_all_diffs(repo,commit1,commit2)
    return repo.diff(commit1,commit2)
  end

  # DiffUtil.get_diffs
  #
  # given a repo, two SHAs, and a string (containing any combination of
  # A,D,R,M), this function will get the files that are
  # added/deleted/renamed/modified based on what's specified and then return
  # that Array.
  def DiffUtil.get_diffs(repo,commit1,commit2,types)
    diffs = repo.diff(commit1,commit2)

    return diffs.map { |diff| types.include?('A') && diff.new_file ? diff :
      types.include?('D') && diff.deleted_file ? diff :
      types.include?('R') && diff.renamed_file ? diff :
      types.include?('M') && !diff.new_file && !diff.deleted_file && !diff.renamed_file ? diff :
      nil }.compact
  end

  # DiffUtil.get_added_paths
  #
  # given a repo and two SHAs, this function will return a list of the path
  # names for the added files.
  def DiffUtil.get_added_paths(repo,commit1,commit2)
    return DiffUtil.get_added_diffs(repo,commit1,commit2).map { |diff| diff.b_path }
  end

  # DiffUtil.get_deleted_paths
  #
  # given a repo and two SHAs, this function will return a list of the path
  # names for the deleted files.
  def DiffUtil.get_deleted_paths(repo,commit1,commit2)
    return DiffUtil.get_deleted_diffs(repo,commit1,commit2).map { |diff| diff.a_path }
  end

  # DiffUtil.get_renamed_paths
  #
  # given a repo and two SHAs, this function will return a list of the new
  # paths names for the renamed files.
  def DiffUtil.get_renamed_paths(repo,commit1,commit2)
    return DiffUtil.get_renamed_diffs(repo,commit1,commit2).map { |diff| diff.b_path }
  end

  # DiffUtil.get_modified_paths
  #
  # given a repo and two SHAs, this function will return a list of the path
  # names for the modified files.
  def DiffUtil.get_modified_paths(repo,commit1,commit2)
    return DiffUtil.get_modified_diffs(repo,commit1,commit2).map { |diff| diff.b_path }
  end

  # DiffUtil.get_all_paths
  #
  # given a repo and two SHAs, this function will return a list of the path
  # names for all files in the diff.
  def DiffUtil.get_all_paths(repo,commit1,commit2)
    return DiffUtil.get_all_diffs(repo,commit1,commit2).map { |diff| DiffUtil.get_diff_path(diff) }
  end

  # DiffUtil.get_diff_path
  #
  # given a diff object, this function will determine what kind of change
  # the diff is, extract the appropriate dw name for that diff, and then return
  # that path.
  def DiffUtil.get_diff_path(diff)
    if diff.new_file
      return diff.b_path
    elsif diff.deleted_file
      return diff.a_path
    elsif diff.renamed_file
      return diff.b_path
    else
      return diff.a_path
    end
  end

  # DiffUtil.get_status_added
  #
  # given a repo object, this function will get all the status objects that
  # have been added to the working copy (index) and return them as an Array.
  def DiffUtil.get_status_added(repo)
    return repo.status.added.map { |name,status| status }
  end

  # DiffUtil.get_status_deleted
  #
  # given a repo object, this function will get all the status objects that
  # have been deleted from the working copy (index) and return them as an
  # Array.
  def DiffUtil.get_status_deleted(repo)
    return repo.status.deleted.map { |name,status| status }
  end

  # DiffUtil.get_status_changed
  #
  # given a repo object, this function will get all the status objects that
  # have been modified in the working copy and return them as an Array.
  def DiffUtil.get_status_changed(repo)
    return repo.status.changed.map { |name,status| status }
  end

  # DiffUtil.get_status_all
  #
  # given a repo object, this function will get all the status objects that
  # have been either added, deleted, or changed in the working copy and
  # return them as an Array.
  def DiffUtil.get_status_all(repo)
    return DiffUtil.get_status_added(repo) + DiffUtil.get_status_deleted(repo) + DiffUtil.get_status_changed(repo)
  end

  # DiffUtil.get_status_added_paths
  #
  # given a repo object, this function will get all the status item paths for
  # files that have been added to the working copy and return them as an
  # Array.
  def DiffUtil.get_status_added_paths(repo)
    return repo.status.added.map { |name, status| name }
  end

  # DiffUtil.get_status_deleted_paths
  #
  # given a repo object, this function will get all the status item paths
  # for the files that have been deleted from the working copy and return
  # them as an Array.
  def DiffUtil.get_status_deleted_paths(repo)
    return repo.status.deleted.map { |name, status| name }
  end

  # DiffUtil.get_status_changed_paths
  #
  # given a repo object, this function will get all the status item paths
  # for the files that have been changed in the working copy and return them
  # as an Array.
  def DiffUtil.get_status_changed_paths(repo)
    return repo.status.changed.map { |name,status| name }
  end

  # DiffUtil.get_status_all_paths
  #
  # given a repo object, this function will get all the status item paths
  # for all the files that have been either added, deleted, or changed in
  # the working copy and return them as an Array.
  def DiffUtil.get_status_all_paths(repo)
    return DiffUtil.get_status_added_paths(repo) + DiffUtil.get_status_deleted_paths(repo) + DiffUtil.get_status_changed_paths(repo)
  end

end

if __FILE__==$0
  main()
end
