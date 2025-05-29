require 'toml-rb'
require 'grpc'
require_relative './namenode_logic'
require_relative '../grpc/services/namenode_services_pb'

class HDFSNameNodeService < Namenode::NameNodeService::Service
  attr_reader :server_name 
  attr_reader :server_ordinal
  attr_reader :server_name_node
  attr_reader :server_config
  attr_reader :server

	def initialize()
    # Load identification
		@server_name = ENV['HOSTNAME'] || 'localhost-0'
		@server_ordinal = @server_name.split('-').last.to_i

    # Load configuration
		@server_config = TomlRB.load_file(
      "D:/Coding Stuff/Ruby Projects/Hadoop Simulation/sim_config.toml"
		)

		# Create name node object
		@server_name_node = HDFSNameNode.new(@server_name, @server_ordinal)
	end
  
  def start_server()
    # Create socket address
    ip_addr = @server_config["hdfs_listen_addr"]
    port = @server_config["hdfs_listen_port"]
    socket = ip_addr + ":" + port.to_s

    # Create the server
    @server = GRPC::RpcServer.new
    @server.add_http2_port(socket, :this_port_is_insecure)
    @server.handle(self)
    @server.run_till_terminated
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
