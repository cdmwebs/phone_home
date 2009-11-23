class PhoneHome
  class ImageCapture
    attr_reader :command, :output_path, :image_name

    def initialize(options = {})
      @command = options[:command]
      @output_path = options[:output_path]
      @image_name = options[:image_name] || 'image'

      raise ConfigurationError, "Must supply an image capture command and an output path" unless @command && @output_path
      raise ConfigurationError, "Cannot write to requested output path" unless assure_path
    end

    def capture
      `"#{@command} #{@output_path}/#{safe_date}-#{@image_name}.jpg"`
    end

    private
    def assure_path
      unless Dir.glob(@output_path).size>0
        begin
          Dir.mkdir @output_path, 0755
        rescue
          return false
        end
      end
      true
    end

    def safe_date
      Time.now.strftime('%Y%m%d.%H%M%S')
    end
  end
end
