require 'git'

def sparse_checkout(repo_url, local_path, sparse_paths = [])
  # Clone repo with no checkout
  system("git clone --no-checkout #{repo_url} #{local_path}")
  Dir.chdir(local_path) do
    # Enable sparse checkout
    system("git config core.sparseCheckout true")

    # Write sparse paths
    File.open(".git/info/sparse-checkout", "w") do |f|
      sparse_paths.each { |path| f.puts(path) }
    end

    # Checkout specified paths
    system("git checkout")
  end
end