# File: /etc/chef/handlers/elastic_log_handler.rb

require 'chef/handler'
require 'fileutils'
require 'json'
require 'time'

module ElasticChef
  class LogHandler < Chef::Handler
    def report
      base_dir = "/var/log/chef"
      log_dir = File.join(base_dir, "elastic_chef_logs")
      rotate_logs_if_needed(log_dir)

      FileUtils.mkdir_p(log_dir) unless Dir.exist?(log_dir)

      timestamp = Time.now.utc.iso8601
      hostname = node.name || Socket.gethostname
      filename = "chef_log_#{hostname}_#{Time.now.utc.strftime('%Y%m%d_%H%M%S')}.json"
      log_file = File.join(log_dir, filename)

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

    private

    def rotate_logs_if_needed(log_dir)
      return unless Dir.exist?(log_dir) && Dir.children(log_dir).any?

      timestamp = Time.now.utc.strftime('%Y%m%d_%H%M%S')
      archive_dir = "#{log_dir}_archive_#{timestamp}"

      FileUtils.mkdir_p(archive_dir)
      Dir.children(log_dir).each do |file|
        FileUtils.mv(File.join(log_dir, file), File.join(archive_dir, file))
      end
    end
  end
end
