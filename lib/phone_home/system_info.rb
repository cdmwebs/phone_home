class PhoneHome
  class SystemInfo
    attr_reader :output_path

    def initialize(output_path)
      @output_path = output_path
    end

    def report(output_path=nil)
      line = "IP Address: #{external_ip}\nComputer Name: #{computer_name}Logged In: #{logged_in}Last Users:\n#{last_users}"
      output_path ? output_path.write(line) : line
    end

    def report_to_file
      folder = FileUtils.mkdir_p(output_folder)
      File.open("#{output_folder}/#{safe_date}-#{external_ip}.txt", "w") do |file|
        report(file) 
      end
    end

    private
    def external_ip
      ip_address = open("http://checkip.dyndns.org") do |f|
        /([0-9]{1,3}\.){3}[0-9]{1,3}/.match(f.read)[0].to_a[0]
      end
      return ip_address
    end

    def computer_name
      name = `(/bin/hostname)`
    end

    def logged_in
      return `/usr/bin/whoami`
    end

    def last_users
      return `/usr/bin/last | tail`
    end

    def safe_date
      return Time.now.strftime('%Y%m%d.%H%M%S')
    end

#    def profiler
#      unless @profile
#        @profile = `/usr/sbin/system_profiler -detailLevel -3`
#        @profile = @profile.split("\n").each do |line|
#          line.strip!
#        end
#      end
#    end
  end
end
