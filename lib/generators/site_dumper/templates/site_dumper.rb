require 'site_dumper'

SiteDumper.setup do |config|
  ## directories with user generated content
  # config.dumped_filepaths = [Rails.root.join('public/assets')]

  ## default email for dump sending
  config.admin_email = 'admin_email_here'

  ## default email for "from" field
  config.robot_email = '<robot@mysite.com>'

  ## if email exceeds size limit of SMTP server dump will be sliced by parts
  config.max_email_size = '10 Mb' # Kb, Mb, Gb
end