require 'toml-rb'
require 'socket'
require_relative './namenode-logic'

class HDFSNameNodeServer
  	attr_reader :server_name, :server_ordinal, :server_name_node

	def initialize()
    	# Load identification
		@server_name = ENV['HOSTNAME'] || 'localhost-0'
		@server_ordinal = @server_name.split('-').last.to_i

    	# Load configuration
		config = TomlRB.load_file(
      		"D:/Coding Stuff/Ruby Projects/Hadoop Simulation/sim_config.toml"
		)

		# Create name node object
		@server_name_node = HDFSNameNode.new(
			@server_name, @server_ordinal, config
		)
	end
end