require File.dirname(__FILE__) + '/../test_helper'

class PhoneHome::UploadTest < Test::Unit::TestCase
  context 'initialization' do
    setup do
      create_default_attributes
    end

    [:host_name, :user_name, :local_path, :remote_path].each do |required_attr|
      should "require #{required_attr} to be supplied" do
        @upload_attributes.delete required_attr
        assert_raises PhoneHome::ConfigurationError do
          PhoneHome::Upload.new @upload_attributes
        end
      end
    end

    should "support configuration of an ssh key" do
      @upload_attributes = @upload_attributes.merge :ssh_key => '/Users/cdmwebs/.ssh/id_rsa.pub'
      File.expects(:"exists?").with('/Users/cdmwebs/.ssh/id_rsa.pub').returns(true)
      PhoneHome::Upload.new @upload_attributes
    end
  end

  context "transmitting files to remote host" do
    setup do
      create_default_attributes
      set_scp_expectations @upload_attributes[:host_name], @upload_attributes[:user_name], @upload_attributes[:local_path], @upload_attributes[:remote_path]
      @uploader = PhoneHome::Upload.new @upload_attributes
    end

    should "use scp to recursively post files to the remote host" do
      @uploader.post
    end
  end

  context "transmitting files to remote host using ssh key" do
    setup do
      create_default_attributes
      set_scp_expectations @upload_attributes[:host_name], @upload_attributes[:user_name], @upload_attributes[:local_path], @upload_attributes[:remote_path], :ssh_key=>'/Users/cdmwebs/.ssh/id_rsa.pub'
      File.expects(:"exists?").with('/Users/cdmwebs/.ssh/id_rsa.pub').returns(true)
      @uploader = PhoneHome::Upload.new @upload_attributes.merge :ssh_key =>'/Users/cdmwebs/.ssh/id_rsa.pub' 
    end

    should "use scp with an ssh key when posting files if an ssh key was supplied" do
      @uploader.post
    end
  end

  def create_default_attributes
      @upload_attributes = {
        :host_name   => '26webs.com',
        :user_name   => 'cdmwebs',
        :local_path  => '/tmp/output',
        :remote_path => 'mac-status'
      }
  end

  def set_scp_expectations(host, user, local_path, remote_path, options={})
    ssh_options = {:recursive=>true}
    ssh_options = ssh_options.merge(:key=>options[:ssh_key]) if options.include?(:ssh_key)
    Net::SCP.expects(:upload!).with(host, user, local_path, remote_path, ssh_options).returns(true)
  end
end
