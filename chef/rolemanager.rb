require 'json'
require 'fileutils'

class RoleManager
  def initialize(cookbook_path)
    @roles_path = File.join(cookbook_path, 'roles')
    FileUtils.mkdir_p(@roles_path)
  end

  ## Create New Role (Fails if role already exists)
  def create_role(role_name, run_list = [], attributes = {})
    role_file = role_file_path(role_name)
    if File.exist?(role_file)
      puts "Role '#{role_name}' already exists. Use edit_role to modify it."
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
      puts "Role '#{role_name}' does not exist. Use create_role to create it first."
      return
    end

    role_data = JSON.parse(File.read(role_file))

    # Ensure run_list exists
    role_data["run_list"] ||= []

    # Add run_list items (avoid duplicates)
    add_run_list.each do |item|
      role_data["run_list"] << item unless role_data["run_list"].include?(item)
    end

    # Remove run_list items
    remove_run_list.each do |item|
      role_data["run_list"].delete(item)
    end

    # Update attributes with deep merge
    role_data["default_attributes"] ||= {}
    deep_merge!(role_data["default_attributes"], update_attributes)

    File.write(role_file, JSON.pretty_generate(role_data))
    puts "Role '#{role_name}' updated successfully in cookbook."
  end

  ## Delete Existing Role
  def delete_role(role_name)
    role_file = role_file_path(role_name)
    if File.exist?(role_file)
      File.delete(role_file)
      puts "Role '#{role_name}' deleted from cookbook."
    else
      puts "Role '#{role_name}' does not exist."
    end
  end

  ## Helper to Get Role JSON File Path
  def role_file_path(role_name)
    File.join(@roles_path, "#{role_name}.json")
  end

  ## Deep Merge Helper for Attributes
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