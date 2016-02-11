
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

  def dump_part from, to, dump_part_filepath, time, index, length
    attachments.inline[File.basename(dump_part_filepath)] = File.read(dump_part_filepath)
    mail(from: from, to: to, subject: "Site successfully dumped at #{time} (part #{index + 1} of #{length})", ) do |format|
      format.text { render text: "Dump succesfully generated! Part #{index + 1} of #{length}.\n" +
        "You can split it using `cat dump_1970-01-01.tar.* > dump_1970-01-01.tar`"}
    end
  end

  def error from, to, errors
    mail(from: from, to: to, subject: "Site dump error at #{Time.new.to_formatted_s(:db)}", ) do |format|
      format.text { render text: "Dump generation errors:\n" + errors.join("\n") }
    end
  end
end