require File.dirname(__FILE__) + '/../test_helper'

class PhoneHome::WatcherTest < Test::Unit::TestCase
  context "initialization" do
    should "require an io and a match" do
      assert_raise ArgumentError do
        PhoneHome::Watcher.new
      end
    end

    should "be valid if url is parseable" do
      @watcher = PhoneHome::Watcher.new('http://github.com', 'ok')
      assert @watcher.valid?
    end

    should "not be valid if url is borked" do
      @watcher = PhoneHome::Watcher.new('goobeldegoo', 'ok')
      assert_equal @watcher.valid?, false
    end

    should "not be valid unless url uses http or https" do
      @watcher = PhoneHome::Watcher.new('ftp://myjunk.org/file', 'ok')
      assert_equal @watcher.valid?, false
    end

    should "not be valid unless match is a string or regex" do
      @watcher = PhoneHome::Watcher.new('http://myjunk.org/file', 'ok')
      assert @watcher.valid?
      @watcher = PhoneHome::Watcher.new('http://myjunk.org/file', /ok/)
      assert @watcher.valid?
      @watcher = PhoneHome::Watcher.new('http://myjunk.org/file', 1)
      assert_equal @watcher.valid?, false
    end
  end

  context "validating the match" do
    setup do
      @watcher = PhoneHome::Watcher.new('http://phonehome.org/watch', 'ok')
      create_host_with_watched_file
    end

    should "be true if the watch file includes the supplied match" do
      assert @watcher.matches?
    end

    should "fail if the watch file does not include the supplied match" do
      @watcher.match = 'no luck'
      assert_equal @watcher.matches?, false
    end
  end

  context "server timeout" do
    setup do
      @watcher = PhoneHome::Watcher.new('http://badserver.com/watch', 'ok')
      create_invalid_host
    end

    should "write to the logger" do
      PhoneHome.expects(:log).with('Could not contact the remote watch file server')
      assert @watcher.matches?
    end
  end

  context "watch file not found" do
    setup do
      @watcher = PhoneHome::Watcher.new('http://phonehome.org/junk', 'ok')
      create_host_without_file
    end

    should "write to the logger" do
      PhoneHome::Base.expects(:log).with('Watch file not found on remote server')
      assert !@watcher.matches?
    end
  end

end
