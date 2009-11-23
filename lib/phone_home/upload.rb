class PhoneHome
  class Upload
    def initialize(options={})
      [:host_name, :user_name, :local_path, :remote_path, :ssh_key].each do |inst_var|
        instance_variable_set :"@#{inst_var}", options[inst_var]
      end
      valid?
    end

    def post
      Net::SCP.upload!(@host_name, @user_name, @local_path, @remote_path, ssh_options) do |ch, name, sent, total|
        PhoneHome::Base.log "#{name}: #{sent}/#{total}"
      end
    end

    private
    def valid?
      raise ConfigurationError, "Must supply host_name, user_name, local_path, and remote_path in a hash" if missing_parameters?
      raise ConfigurationError, "Invalid ssh_key supplied" unless valid_ssh_key?
      true
    end

    def missing_parameters?
      @host_name.nil? || @user_name.nil? || @local_path.nil? || @remote_path.nil? 
    end

    def valid_ssh_key?
      return true if @ssh_key.nil?
      File.exists? @ssh_key
    end

    def ssh_options
      options = {:recursive=>true}
      @ssh_key ? options.merge(:key => @ssh_key) : options
    end
  end
end
