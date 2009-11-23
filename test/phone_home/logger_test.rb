require File.dirname(__FILE__) + '/../test_helper'

class LoggerTest < Test::Unit::TestCase
  context "initialization" do
    should "require an output stream" do
      assert_raise ArgumentError do
        PhoneHome::Logger.new
      end

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
