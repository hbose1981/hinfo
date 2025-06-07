require_relative 'role_manager'
require_relative 'node_manager'
require_relative 'auto_logger'

class JenkinsManager
  def initialize(cookbook_path, chef_api_params)
    @role_manager = RoleManager.new(cookbook_path)
    @node_manager = NodeManager.new(chef_api_params)
  end

  # Fetch Jenkins environment parameter with default fallback
  def get_param(name, default = nil)
    ENV[name] || default
  end

  # Read JSON content from file if provided
  def read_json_file(file_path)
    return [] unless file_path && File.exist?(file_path)
    JSON.parse(File.read(file_path))
  rescue JSON::ParserError => e
    warn "Invalid JSON in file '#{file_path}': #{e.message}"
    []
  end

  # Main execution dispatcher based on Jenkins parameters
  def process_job
    action = get_param('ACTION', '').downcase
    role_name = get_param('ROLE_NAME')
    node_name = get_param('NODE_NAME')
    run_list_file = get_param('RUN_LIST_FILE')
    attr_file = get_param('ATTRIBUTES_FILE')

    run_list = read_json_file(run_list_file)
    attributes = read_json_file(attr_file)

    case action
    when 'create_role'
      handle_create_role(role_name, run_list, attributes)
    when 'edit_role'
      handle_edit_role(role_name, run_list, attributes)
    when 'delete_role'
      handle_delete_role(role_name)
    when 'attach_role'
      handle_attach_role(node_name, role_name)
    when 'detach_role'
      handle_detach_role(node_name, role_name)
    else
      warn "Unsupported ACTION: '#{action}'. Valid actions are: create_role, edit_role, delete_role, attach_role, detach_role."
    end
  end

  private

  ## Handlers for Each Action

  def handle_create_role(role_name, run_list, attributes)
    if role_name
      puts "Creating role '#{role_name}'..."
      @role_manager.create_role(role_name, run_list, attributes)
    else
      warn "ROLE_NAME parameter is missing for create_role."
    end
  end

  def handle_edit_role(role_name, run_list, attributes)
    if role_name
      puts "Editing role '#{role_name}'..."
      @role_manager.edit_role(role_name, add_run_list: run_list, update_attributes: attributes)
    else
      warn "ROLE_NAME parameter is missing for edit_role."
    end
  end

  def handle_delete_role(role_name)
    if role_name
      puts "Deleting role '#{role_name}'..."
      @role_manager.delete_role(role_name)
    else
      warn "ROLE_NAME parameter is missing for delete_role."
    end
  end

  def handle_attach_role(node_name, role_name)
    if node_name && role_name
      puts "Attaching role '#{role_name}' to node '#{node_name}'..."
      @node_manager.attach_role(node_name, role_name)
    else
      warn "NODE_NAME or ROLE_NAME parameter missing for attach_role."
    end
  end

  def handle_detach_role(node_name, role_name)
    if node_name && role_name
      puts "Detaching role '#{role_name}' from node '#{node_name}'..."
      @node_manager.detach_role(node_name, role_name)
    else
      warn "NODE_NAME or ROLE_NAME parameter missing for detach_role."
    end
  end
end