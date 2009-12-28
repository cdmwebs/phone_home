class PhoneHome
  class Base
    attr_accessor :logger

    def initialize
    end

    def log(msg)
      @logger ||= Logger.new
    end
  end
end
