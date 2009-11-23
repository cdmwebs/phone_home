require File.dirname(__FILE__) + '/../test_helper'

class LoggerTest < Test::Unit::TestCase
  context "initialization" do
    should "default logging to Syslog if no io stream is specified" do
      phone_home = PhoneHome::Logger.new
      assert_equal Syslog, phone_home.instance_variable_get(:@output_stream)
    end

    should "permit the logging to be directed to another output stream" do
      assert_nothing_raised do
        PhoneHome::Logger.new STDOUT
      end
    end
  end

  context "logging" do
    setup do
      @logger = PhoneHome::Logger.new(STDOUT)
    end

    should "be able to puts a string" do
      STDOUT.expects('puts').with('Send message')
      @logger.puts 'Send message'
    end
  end
end
