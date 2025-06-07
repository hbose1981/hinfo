require 'chef'
require 'json'

class NodeManager
  def initialize(chef_api_params)
    Chef::Config.from_hash(
      chef_server_url: chef_api_params[:chef_server_url],
      node_name: chef_api_params[:client_name],
      client_key: chef_api_params[:client_key],
      ssl_verify_mode: :verify_none # For production, ensure proper SSL verification
    )
  end

  ## Attach Role to Node Run-List
  def attach_role(node_name, role_name)
    node = load_node(node_name)
    return unless node

    role_entry = "role[#{role_name}]"
    unless node.run_list.include?(role_entry)
      node.run_list << role_entry
      node.save
      puts "Attached role '#{role_name}' to node '#{node_name}'."
    else
      puts "Node '#{node_name}' already has role '#{role_name}' in its run_list."
    end
  end

  ## Detach Role from Node Run-List
  def detach_role(node_name, role_name)
    node = load_node(node_name)
    return unless node

    role_entry = "role[#{role_name}]"
    if node.run_list.include?(role_entry)
      node.run_list.remove(role_entry)
      node.save
      puts "Detached role '#{role_name}' from node '#{node_name}'."
    else
      puts "Node '#{node_name}' does not have role '#{role_name}' in its run_list."
    end
  end

  ## Fetch Node's Run-List
  def fetch_node_run_list(node_name)
    node = load_node(node_name)
    return [] unless node

    puts "Run-list for node '#{node_name}': #{node.run_list.to_a}"
    node.run_list.to_a
  end

  private

  def load_node(node_name)
    Chef::Node.load(node_name)
  rescue Net::HTTPServerException => e
    warn "Failed to load node '#{node_name}': #{e.message}"
    nil
  end
end