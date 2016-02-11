require "site_dumper/version"
require 'site_dumper/railtie' if defined?(Rails::Railtie)
require 'active_support/core_ext/module/attribute_accessors'

module SiteDumper
  mattr_accessor :dumped_filepaths

  mattr_accessor :admin_email

  mattr_accessor :robot_email

  mattr_accessor :max_email_size

  class << self
    def setup
      yield self
    end

    # @return [Boolean] true for successful result
    def dump!
      raise "Specify robot email" unless robot_email
      raise "Specify admin email" unless admin_email
      d = nil

      begin
        d = Dumper.new(dumped_filepaths: dumped_filepaths.map(&:to_s), max_email_size: max_email_size)
        d.create
        if d.errors.present?
          Mailer.error(robot_email, admin_email, d.errors.join(", ")).deliver!
          false
        elsif Array(d.result_filepaths).size > 1
          d.result_filepaths.each_with_index do |filepath, index|
            Mailer.dump_part(robot_email, admin_email, filepath, Time.new.to_formatted_s(:db),
                             index, d.result_filepaths.size).deliver!
          end
          true
        else
          Mailer.dump(robot_email, admin_email, d.result_filepaths).deliver!
          true
        end
      rescue Exception => err
        Mailer.error(robot_email, admin_email, [err.to_s] + err.backtrace).deliver!
        false
      ensure
        if d && File.exist?(d.tmp_dir)
          FileUtils.rm_rf(d.tmp_dir)
        end
      end
    end
  end

  autoload :Dumper, 'site_dumper/dumper'
  autoload :Mailer, 'site_dumper/mailer'
end
