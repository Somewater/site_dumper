module SiteDumper
  require 'rails'
  class Railtie < Rails::Railtie
    rake_tasks { load "tasks/site_dumper.rake" }
  end
end