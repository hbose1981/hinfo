class NodeManager
  def initialize(chef_api)
    @chef_api = chef_api
  end

  def attach_role(node_name, role_name)
    @chef_api.add_role_to_node(node_name, role_name)
  end

  def detach_role(node_name, role_name)
    @chef_api.remove_role_from_node(node_name, role_name)
  end
end