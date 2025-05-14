require_relative 'jenkins_manager'

knife_rb_path = "#{ENV['WORKSPACE']}/.chef/knife.rb"
manager = JenkinsManager.new("#{ENV['WORKSPACE']}/roles-cookbook", knife_rb_path)
manager.process_job