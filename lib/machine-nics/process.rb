module MachineNics
  class Process
    def initialize(commands = [])
      @commands = commands
    end
    def execute
      @commands.flatten.each do |cmd|
        output = `#{cmd} 2>&1`
        if $?.exitstatus != 0
          STDERR.puts "Creation of a NIC FAILED (#{$?})"
          STDERR.puts "--\n"
          STDERR.puts "command was:"
          STDERR.puts "#{cmd}"
          STDERR.puts "output was:"
          STDERR.puts "#{output}"
          STDERR.puts "\nAborting ..."
          STDERR.puts "--\n"
          STDERR.puts "Please, create an issue on https://github.com/sathlan/machine-nics"
          STDERR.puts "with this output.  A output of ifconfig and uname -a migth be helpful as well."
          exit 1
        end
      end
    end
  end
end
