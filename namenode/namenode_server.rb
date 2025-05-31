require 'toml-rb'
require 'grpc'
require_relative './namenode_logic'
require_relative '../hdfs_grpc/services/namenode_services_pb'

class HDFSNameNodeService < Namenode::NameNodeService::Service
  attr_reader :server_name 
  attr_reader :server_ordinal
  attr_reader :server_name_node
  attr_reader :server_config
  attr_reader :server

	def initialize(hostname="localhost", ordinal=0)
    # Load identification
		@server_name = hostname + ordinal.to_s
		@server_ordinal = @server_name.split('-').last.to_i

    # Load configuration
    @server_config = TomlRB.load_file("./sim_config.toml")

		# Create name node object
		@server_name_node = HDFSNameNode.new(@server_name, @server_ordinal)
	end
  
  def start_server()
    # Create socket address
    ip_addr = @server_config["network"]["hdfs_listen_addr"]
    port = @server_config["network"]["hdfs_listen_port"]
    socket = ip_addr + ":" + port.to_s

    # Create the credentials
    key = File.read("./hdfs_setup/tls/datanode-0-server.key")
    cert = File.read("./hdfs_setup/tls/datanode-0-server.crt")
    credentials = GRPC::Core::ServerCredentials.new(
      nil, [{ private_key: key, cert_chain: cert }], true
    )

    # Create the server
    @server = GRPC::RpcServer.new
    @server.add_http2_port(socket, credentials)
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
