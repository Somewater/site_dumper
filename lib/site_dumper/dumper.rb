require 'fileutils'
require 'open3'

class SiteDumper::Dumper

  # @attr_reader [Array<String>, nil] Array of errors that occurred during dump generation
  attr_reader :errors

  # @attr_reader Array<String> archive with all dump parts
  attr_reader :result_filepaths

  attr_reader :tmp_dir

  # @param [Hash]
  # @option dumped_filepaths [String, Array<String>]
  def initialize(config)
    @config = HashWithIndifferentAccess.new(config)
  end

  # Create archive with all required dump data
  def create
    @tmp_dir = File.join(Rails.root, 'tmp', 'site_dumper', Time.new.to_i.to_s)
    dumped_filepaths = (@config[:dumped_filepaths] || []).select{|path| Dir.exist?(path) }
    FileUtils.mkdir_p(@tmp_dir)
    files = dump_filepaths(File.join(@tmp_dir, 'files.tar.gz'), dumped_filepaths) if dumped_filepaths.present?
    database = dump_database(File.join(@tmp_dir, 'database.sql.gz'))
    full_dump = nil
    if [files, database].compact.present?
      @result_filepaths = \
        dump_filepaths(File.join(@tmp_dir, "dump_#{Time.new.strftime('%Y-%m-%d')}.tar"),
                       [files, database].compact,
                       @tmp_dir, false)
      if @config[:max_email_size] && (limit = to_bytes(@config[:max_email_size])) > 0 &&
          File.size(@result_filepaths) > limit
        output = @result_filepaths + '.'
        full_dump = @result_filepaths
        cmd("split -b #{limit} #{@result_filepaths} #{output}")
        @result_filepaths = Dir[output + '*'].sort
      end
      @result_filepaths
    end
  ensure
    FileUtils.rm_rf([files, database, full_dump].compact) if [files, database, full_dump].compact.present?
  end

  protected

  def to_bytes(msg)
    if msg.is_a?(String)
      number = msg.to_i
      case msg.downcase
        when /kb/
          1024
        when /mb/
          1024 ** 2
        when /gb/
          1024 ** 3
        else
          1
      end * number
    else
      msg.to_i
    end
  end

  def dump_filepaths(to_file, source_filepaths, root = Rails.root, gzip = true)
    without_root = source_filepaths.map { |path| path.to_s.sub("#{root}/", '') }
    cmd("tar -#{gzip ? 'z' : ''}cf #{to_file} -C #{root} #{without_root.join(' ')}")
    to_file
  rescue Exception
    add_exception_and_raise($!)
  end

  def dump_database(to_file)
    config = Rails.configuration.database_configuration[Rails.env]
    pipes = " | gzip > #{to_file}"

    case config["adapter"]
      when /^mysql/
        args = {
            'host'      => '--host',
            'port'      => '--port',
            'socket'    => '--socket',
            'username'  => '--user',
            'encoding'  => '--default-character-set',
            'password'  => '--password'
        }.map { |opt, arg| "#{arg}=#{config[opt]}" if config[opt] }.compact
        args << config['database']

        cmd("mysqldump #{args.join(' ')} #{pipes}")

      when "postgresql"
        env = {}
        env['PGUSER']     = config["username"] if config["username"]
        env['PGHOST']     = config["host"] if config["host"]
        env['PGPORT']     = config["port"].to_s if config["port"]
        env['PGPASSWORD'] = config["password"].to_s if config["password"]
        cmd("pg_dump #{config["database"]} #{pipes}", env)

      when "sqlite"
        cmd("sqlite' #{config["database"]} .dump #{pipes}")

      when "sqlite3"
        cmd("sqlite3 #{config['database']} .dump #{pipes}")

      else
        raise "Undefined database type #{config["adapter"]}"
    end
    to_file
  rescue Exception
    add_exception_and_raise($!)
  end # dump_database

  def add_exception_and_raise exception
    (@errors ||= []) << exception.to_s
    raise exception
  end

  def cmd command, env = {}
    stdout, stderr, status = Open3.capture3(env, command)
    if !status.success? || stderr.present?
      out = (stderr.presence || stdout)
      raise "Cmd exception: #{out}"
    end
  end
end
