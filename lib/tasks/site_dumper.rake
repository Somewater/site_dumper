namespace :site_dumper do
  desc "Generate site dump and send it to admin email"
  task :dump => :environment do
    SiteDumper.dump!
  end
end