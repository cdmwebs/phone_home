require 'rubygems'
require 'net/http'
require 'net/scp'
require 'open-uri'

class PhoneHome
  class ConfigurationError < StandardError; end

  def initialize(url)
    @watcher = PhoneHome::Watcher.new(url, 'ok')

    @screen  = PhoneHome::ImageCapture.new :command     => '/usr/sbin/screencapture -x -m -t jpg -T 1', 
                                           :output_path => output_folder, 
                                           :image_name  => 'screen'

    @camera  = PhoneHome::ImageCapture.new :command     => '/usr/local/bin/isightcapture -n 1 -t jpg -w 640 -h 480',
                                           :output_path => output_folder, 
                                           :image_name  => 'screen'

    @uploader = PhoneHome::Upload.new :host_name   => '26webs.com',
                                      :user_name   => 'cdmwebs',
                                      :local_path  => output_folder,
                                      :remote_path => 'mac-status',
                                      :ssh_key     => '/Users/cdmwebs/.ssh/id_rsa.pub'

    unless @watcher.matches?
      tell_server
    end
  end

  def tell_server
    write_output
    @screen.capture
    @camera.capture
    @uploader.post
    #cleanup
  end

  def logged_in
    return `/usr/bin/whoami`
  end

  def external_ip
    ip_address = open("http://checkip.dyndns.org") do |f|
      /([0-9]{1,3}\.){3}[0-9]{1,3}/.match(f.read)[0].to_a[0]
    end
    return ip_address
  end

  def computer_name
    name = `(/bin/hostname)`
    #name = @profile.select { |line| line =~ /Computer Name/ }
    #return name[0].split(':')[1].strip! unless name.nil?
    return name
  end

  def last_users
    return `/usr/bin/last | tail`
  end

  def profiler
    unless @profile
      @profile = `/usr/sbin/system_profiler -detailLevel -3`
      @profile = @profile.split("\n").each do |line|
        line.strip!
      end
    end
  end

  def write_output
    line = "IP Address: #{external_ip}\nComputer Name: #{computer_name}Logged In: #{logged_in}Last Users:\n#{last_users}"
    folder = FileUtils.mkdir_p(output_folder)
    File.open("#{output_folder}/#{safe_date}-#{external_ip}.txt", "w") do |file|
      file.write(line)
    end
  end

  private

  def safe_date
    return Time.now.strftime('%Y%m%d.%H%M%S')
  end

  def output_folder
    return '/tmp/output'
  end

  def cleanup
    FileUtils.rm_rf output_folder
  end

  def logger(msg)
    @logger ||= PhoneHome::Logger.new
    @logger.puts msg
  end
end

directory = File.expand_path(File.dirname(__FILE__)) + '/phone_home'
Dir.glob(directory + '/*.rb').each do |required_file|
  require required_file
end
