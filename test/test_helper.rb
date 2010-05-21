require 'rubygems'
require 'test/unit'
require 'pathname'

gem 'shoulda', '>= 2.10.1'
gem 'mocha'
gem 'fakeweb', '>=1.2.7'

require 'shoulda'
require 'mocha'
require 'fakeweb'

dir = (Pathname(__FILE__).dirname + '../lib').expand_path
require dir + 'phone_home'
    
FakeWeb.allow_net_connect = false

class Test::Unit::TestCase
  def run(result)
    puts self.name
    super
  end 
end

def create_invalid_host
  FakeWeb.register_uri(:any, 'http://badserver.com/watch', :exception => Net::HTTPServerError)
end

def create_host_without_file
  FakeWeb.register_uri(:get, 'http://phonehome.org/junk', :status => ['404', 'Not Found'])
end

def create_host_with_watched_file
  FakeWeb.register_uri(:get, 'http://phonehome.org/watch', :body => 'Chris is ok')
end
