class PhoneHome
  class Logger
    require 'syslog'

    def initialize(io = Syslog)
      @output_stream = io
    end

    def puts(msg)
      case
        when @output_stream.respond_to?(:info)
          @output_stream.info msg
        when @output_stream.respond_to?(:puts)
          @output_stream.puts msg
      end
    end
  end
end
