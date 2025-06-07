require 'git'
require 'fileutils'

class BitbucketManager
  def initialize(repo_url, local_path, username, password)
    @repo_url = repo_url.sub('https://', "https://#{username}:#{password}@")
    @local_path = local_path
  end

  def clone_repo
    unless Dir.exist?(@local_path)
      puts "Cloning repository..."
      Git.clone(@repo_url, @local_path)
    else
      puts "Repository already cloned."
    end
  end

  def pull_latest
    g = Git.open(@local_path)
    g.pull
  end

  def add_file(file_path, content)
    full_path = File.join(@local_path, file_path)
    FileUtils.mkdir_p(File.dirname(full_path))
    File.write(full_path, content)
  end

  def delete_file(file_path)
    full_path = File.join(@local_path, file_path)
    File.delete(full_path) if File.exist?(full_path)
  end

  def commit_and_push(commit_message)
    g = Git.open(@local_path)
    g.add(all: true)
    g.commit(commit_message)
    g.push
  end

  def update_metadata_version(new_version)
    metadata_file = File.join(@local_path, 'metadata.rb')
    return unless File.exist?(metadata_file)

    content = File.read(metadata_file)
    content.gsub!(/version\s+['"][\d\.]+['"]/, "version \"#{new_version}\"")
    File.write(metadata_file, content)
  end
end