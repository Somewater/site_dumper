module SiteDumper
  module Generators
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path("../templates", __FILE__)

      desc "creates an initializer file at config/initializers/site_dumper.rb"

      def generate_initialization
        copy_file 'site_dumper.rb', 'config/initializers/site_dumper.rb'
      end
    end
  end
end