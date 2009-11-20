class PhoneHome
  class Watcher
    attr_accessor :match

    def initialize(url, match)
      @url = url
      self.match = match
    end

    def match=(match)
      @match = match.is_a?(String) ? Regexp.new(match) : match
    end

    def matches?
      raise PhoneHome::ConfigurationError unless valid?
      !!(watch_file =~ @match)
    end

    def valid?
      @parsed = URI.parse(@url)
      return false unless @parsed.scheme && @parsed.scheme =~ /^http/
      return false unless @match.is_a?(Regexp)
      true
    end

    private

    def watch_file
      begin
        Net::HTTP.start(@parsed.host, @parsed.port) do |request|
          @response = request.get(@parsed.path)
        end

        case 
        when @response.code =~ /^5.*/
          PhoneHome.log 'Could not contact the remote watch file server'
        when @response.code =~ /^4.*/
          PhoneHome.log 'Watch file not found on remote server'
        when @response.code == '200' 
          return @response.body
        else
        end
        
      rescue
        PhoneHome.log 'Could not contact the remote watch file server'
        return @match.to_s
      end
    end
  end
end
