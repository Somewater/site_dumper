require "site_dumper/version"
require 'site_dumper/railtie' if defined?(Rails::Railtie)

module SiteDumper
  mattr_accessor :dumped_filepaths

  mattr_accessor :admin_email

  mattr_accessor :robot_email

  class << self
    def setup
      yield self
    end

    # @return [Boolean] true for successful result
    def dump!
      raise "Specify robot email" unless robot_email
      raise "Specify admin email" unless admin_email

      begin
        d = Dumper.new(dumped_filepaths: dumped_filepaths.map(&:to_s))
        d.create
        if d.errors.present?
          Mailer.error(robot_email, admin_email, d.errors.join(", ")).deliver!
          false
        else
          Mailer.dump(robot_email, admin_email, d.result_filepath).deliver!
          true
        end
      rescue Exception => err
        Mailer.error(robot_email, admin_email, [err.to_s]).deliver!
        false
      end
    end
  end

  autoload :Dumper, 'site_dumper/dumper'
  autoload :Mailer, 'site_dumper/mailer'
end
