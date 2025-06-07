require 'chef'
require 'json'

class ChefManager
  def initialize(chef_server_url, client_name, signing_key_filename)
    Chef::Config.from_hash(
      chef_server_url: chef_server_url,
      node_name: client_name,
      client_key: signing_key_filename,
      ssl_verify_mode: :verify_none # Optional: Set proper verification in production
    )
  end

  ## Role Management

  def create_or_update_role(role_name, run_list = [], attributes = {})
    role = fetch_role(role_name) || Chef::Role.new
    role.name(role_name)
    role.run_list(run_list)
    role.default_attributes(attributes)
    role.save
    puts "Role '#{role_name}' created or updated."
  end

  def delete_role(role_name)
    role = fetch_role(role_name)
    if role
      role.destroy
      puts "Role '#{role_name}' deleted."
    else
      puts "Role '#{role_name}' does not exist."
    end
  end

  def fetch_role(role_name)
    Chef::Role.load(role_name)
  rescue Net::HTTPServerException
    nil
  end

  ## Node Run-List Management

  def attach_role_to_node(node_name, role_name)
    node = Chef::Node.load(node_name)
    unless node.run_list.include?("role[#{role_name}]")
      node.run_list << "role[#{role_name}]"
      node.save
      puts "Role '#{role_name}' attached to node '#{node_name}'."
    end
  end

  def detach_role_from_node(node_name, role_name)
    node = Chef::Node.load(node_name)
    if node.run_list.include?("role[#{role_name}]")
      node.run_list.remove("role[#{role_name}]")
      node.save
      puts "Role '#{role_name}' detached from node '#{node_name}'."
    end
  end

  def fetch_node_run_list(node_name)
    node = Chef::Node.load(node_name)
    node.run_list
  end
end