require File.dirname(__FILE__) + '/../test_helper'
require 'syslog'

class PhoneHome::BaseTest < Test::Unit::TestCase
  context "reporting errahs" do
    setup do
      @phone_home = PhoneHome::Base.new
    end

    should "be able to log a message" do
      assert_nothing_raised do
        @phone_home.log 'message'
      end
    end

    should "create a default logger if asked to log without initializing the logger" do
      assert_nil @phone_home.logger
      @phone_home.log 'output message'
      assert_not_nil @phone_home.logger
    end

    should "be able to set a custom logger" do
      assert_nothing_raised do 
        @phone_home.logger = PhoneHome::Logger.new(STDOUT)
        @phone_home.log 'output message'
      end
    end
  end
end
