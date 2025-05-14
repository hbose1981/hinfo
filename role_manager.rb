require 'json'
require 'fileutils'

class RoleManager
  def initialize(cookbook_path)
    @roles_path = File.join(cookbook_path, 'roles')
    FileUtils.mkdir_p(@roles_path)
    puts "Initialized RoleManager with path: #{@roles_path}"
  end

  ## Create a New Role (Fails if role already exists)
  def create_role(role_name, run_list = [], attributes = {})
    role_file = role_file_path(role_name)
    if File.exist?(role_file)
      warn "Role '#{role_name}' already exists. Use edit_role to modify it."
      return
    end

    role_data = {
      "name" => role_name,
      "description" => "Role: #{role_name}",
      "run_list" => run_list.uniq,
      "default_attributes" => attributes
    }

    File.write(role_file, JSON.pretty_generate(role_data))
    puts "Role '#{role_name}' created successfully in cookbook."
  end

  ## Edit Existing Role (Add/Remove Run-List Items and Update Attributes)
  def edit_role(role_name, add_run_list: [], remove_run_list: [], update_attributes: {})
    role_file = role_file_path(role_name)
    unless File.exist?(role_file)
      warn "Role '#{role_name}' does not exist. Use create_role to create it first."
      return
    end

    role_data = load_role_data(role_file)

    # Add run_list items (avoid duplicates)
    add_run_list.each do |item|
      unless role_data["run_list"].include?(item)
        role_data["run_list"] << item
        puts "Added '#{item}' to run_list of role '#{role_name}'."
      end
    end

    # Remove run_list items
    remove_run_list.each do |item|
      if role_data["run_list"].delete(item)
        puts "Removed '#{item}' from run_list of role '#{role_name}'."
      end
    end

    # If run_list becomes empty, delete the role JSON
    if role_data["run_list"].empty?
      delete_role(role_name)
      puts "Role '#{role_name}' deleted automatically as run_list became empty."
      return
    end

    # Merge attributes deeply
    role_data["default_attributes"] ||= {}
    deep_merge!(role_data["default_attributes"], update_attributes)

    File.write(role_file, JSON.pretty_generate(role_data))
    puts "Role '#{role_name}' updated successfully in cookbook."
  end

  ## Delete Role JSON File
  def delete_role(role_name)
    role_file = role_file_path(role_name)
    if File.exist?(role_file)
      File.delete(role_file)
      puts "Role '#{role_name}' deleted from cookbook."
    else
      warn "Role '#{role_name}' does not exist."
    end
  end

  ## Fetch Role Data (For Inspection or Debugging)
  def fetch_role(role_name)
    role_file = role_file_path(role_name)
    if File.exist?(role_file)
      role_data = load_role_data(role_file)
      puts "Role '#{role_name}': #{JSON.pretty_generate(role_data)}"
      role_data
    else
      warn "Role '#{role_name}' does not exist."
      nil
    end
  end

  private

  def role_file_path(role_name)
    File.join(@roles_path, "#{role_name}.json")
  end

  def load_role_data(role_file)
    JSON.parse(File.read(role_file))
  end

  ## Recursive Deep Merge for Attributes
  def deep_merge!(original, updates)
    updates.each do |key, value|
      if value.is_a?(Hash) && original[key].is_a?(Hash)
        deep_merge!(original[key], value)
      else
        original[key] = value
      end
    end
  end
end