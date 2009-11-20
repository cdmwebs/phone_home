require 'net/http'
require 'net/scp'
require 'open-uri'

class PhoneHome
  class ConfigurationError < StandardError
  end

  def initialize(url)
    @url = URI.parse(url)

    unless okay?
      tell_server
    end
  end

  def check_status
    @response = Net::HTTP.start(@url.host, @url.port) do |http|
      http.get(@url.path)
    end
    return @response.body.gsub!(/\n/, '')
  end

  def okay?
    check_status == 'ok'
  end

  def tell_server
    write_output
    capture_screen
    capture_image
    upload
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

  def capture_screen
    `/usr/sbin/screencapture -x -m -t jpg -T 1 "#{output_folder}/#{safe_date}-screen.jpg"`
  end

  def capture_image
    `/usr/local/bin/isightcapture -n 1 -t jpg -w 640 -h 480 "#{output_folder}/#{safe_date}-isight.jpg"`
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

  def host_name
    return '26webs.com'
  end

  def user_name
    return 'cdmwebs'
  end

  def remote_path
    return 'mac-status'
  end

  def upload
    Net::SCP.upload!(host_name, user_name, output_folder, remote_path, :key => '/Users/cdmwebs/.ssh/id_rsa.pub', :recursive => true) do |ch, name, sent, total|
      puts "#{name}: #{sent}/#{total}"
    end
  end

  def cleanup
    FileUtils.rm_rf output_folder
  end

  def logger(msg)
    require 'syslog'
    Syslog.info(msg)
  end
end

directory = File.expand_path(File.dirname(__FILE__))
require File.join(directory, 'phone_home', 'watcher')
