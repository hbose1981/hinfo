# File: /etc/chef/handlers/elastic_log_handler.rb

require 'chef/handler'
require 'fileutils'
require 'json'
require 'time'

module ElasticChef
  class LogHandler < Chef::Handler
    def report
      log_dir = "/var/log/chef/elastic_chef_logs"
      FileUtils.mkdir_p(log_dir) unless Dir.exist?(log_dir)

      timestamp = Time.now.utc.iso8601
      hostname = node.name || Socket.gethostname
      log_file = File.join(log_dir, "chef_log_#{hostname}_#{Time.now.to_i}.json")

      structured_log = {
        timestamp: timestamp,
        hostname: hostname,
        chef_run_status: run_status.success? ? "success" : "failure",
        start_time: run_status.start_time.utc.iso8601,
        end_time: run_status.end_time.utc.iso8601,
        elapsed_time_sec: run_status.elapsed_time,
        total_resources: run_status.all_resources.size,
        updated_resources: run_status.updated_resources.map(&:to_s),
        exception: run_status.failed? ? {
          class: run_status.exception.class.to_s,
          message: run_status.exception.message,
          backtrace: run_status.exception.backtrace
        } : nil
      }

      File.open(log_file, "w") do |f|
        f.write(JSON.pretty_generate(structured_log))
      end
    end
  end
end
