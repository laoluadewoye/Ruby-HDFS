require 'toml-rb'
require 'socket'
require 'namenode-logic'

class HDFSNameNodeServer
  	attr_reader :hostname, :ordinal, :server_config

	def initialize()
		@hostname = ENV['HOSTNAME'] || 'localhost-0'
		@ordinal = @hostname.split('-').last.to_i
		@server_config = TomlRB.load_file("D:/Coding Stuff/Ruby Projects/Hadoop Simulation/sim_config.toml")
	end
end