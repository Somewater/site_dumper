
base_class = if defined?(ApplicationMailer)
               ApplicationMailer
             else
               ActionMailer::Base
             end
class SiteDumper::Mailer < base_class
  def dump from, to, dump_filepath
    attachments.inline[File.basename(dump_filepath)] = File.read(dump_filepath)
    mail(from: from, to: to, subject: "Site successfully dumped at #{Time.new.to_formatted_s(:db)}", ) do |format|
      format.text { render text: 'Dump succesfully generated!' }
    end
  end

  def error from, to, errors
    mail(from: from, to: to, subject: "Site dump error at #{Time.new.to_formatted_s(:db)}", ) do |format|
      format.text { render text: "Dump generation errors:\n" + errors.join("\n") }
    end
  end
end