require 'toml-rb'
require_relative './namenode-logic'
require_relative '../grpc/services/namenode_services_pb'

class HDFSNameNodeService < Namenode::NameNodeService::Service
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

  def ingest_file(request, _call)
    raw_response = @server_name_node.process_ingest_file_request(request)
    return Namenode::IngestFileResponse.new(
      success: raw_response[:success],
      message: raw_response[:message]
    )
  end

  def retrieve_file(request, _call)
    raw_response = @server_name_node.process_retrieve_file_request(request)
    return Namenode::RetrieveFileResponse.new(
      success: raw_response[:success],
      message: raw_response[:message],
      file: raw_response[:file],
      checksum: raw_response[:checksum]
    ) 
  end
end
