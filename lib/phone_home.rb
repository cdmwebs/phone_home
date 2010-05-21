gem 'net-scp', '>= 1.0.2'

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

    @system_info = PhoneHome::SystemInfo.new output_folder

    unless @watcher.matches?
      tell_server
    end
  end

  def tell_server
    @system_info.report_to_file
    @screen.capture
    @camera.capture
    @uploader.post
    #cleanup
  end


  private

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
