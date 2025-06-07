module AutoLogger
  def self.enable!
    # Backup Original Methods
    Kernel.module_eval do
      alias_method :original_puts, :puts unless method_defined?(:original_puts)
      alias_method :original_warn, :warn unless method_defined?(:original_warn)

      # Override puts with Timestamped INFO logs
      def puts(*args)
        args.each do |msg|
          original_puts "[#{Time.now.strftime('%Y-%m-%d %H:%M:%S')}] INFO: #{msg}"
        end
      end

      # Override warn with Timestamped WARN logs
      def warn(*args)
        args.each do |msg|
          original_warn "[#{Time.now.strftime('%Y-%m-%d %H:%M:%S')}] WARN: #{msg}"
        end
      end
    end
  end
end

# Enable it immediately when required
AutoLogger.enable!