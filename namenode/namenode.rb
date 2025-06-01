require 'grpc'
require 'toml-rb'
require_relative 'namenode_core_server'
require_relative 'namenode_data_server'

class HDFSNameNode
  attr_reader :namenode_name 
  attr_reader :namenode_ordinal
  attr_reader :is_primary
  attr_reader :namenode_config
  attr_reader :namenode_server

	def initialize(hostname="localhost", ordinal=0)
    # Load identification
		@namenode_name = hostname + '-' + ordinal.to_s()
		@namenode_ordinal = @namenode_name.split('-').last.to_i()

    # Primary namenode status
		if @namenode_ordinal == 0
			@is_primary = true
		else
			@is_primary = false
		end

    # Load configuration
    @namenode_config = TomlRB.load_file("./sim_config.toml")

    # Load gRPC services and server
    @core_service = NameNodeCoreService.new(self)
    @data_service = NameNodeDataService.new(self)
    @namenode_server = create_server()
	end

  def create_server()
    # Create socket address
    ip_addr = @namenode_config["network"]["hdfs_listen_addr"]
    port = @namenode_config["network"]["hdfs_listen_port"]
    socket = ip_addr + ":" + port.to_s()

    # Create the credentials
    credentials = GRPC::Core::ServerCredentials.new(
      File.read("./hdfs_setup/tls/simulation-ca-server.crt"), 
      [
        { 
          private_key: File.read("./hdfs_setup/tls/localhost-server.key"), 
          cert_chain: File.read("./hdfs_setup/tls/localhost-server.crt") 
        }
      ], 
      true
    )

    # Create the server
    new_server = GRPC::RpcServer.new()
    new_server.add_http2_port(socket, credentials)
    new_server.handle(@core_service)
    new_server.handle(@data_service)

    return new_server
  end

  def start_server()
    @namenode_server.run_till_terminated()
  end

  def handle_received_chunk(chunk_data)
  end

  def create_receive_chunks_response(session_info)
    # return {
    #   "response_success" => true,
    #   "response_message" => "Test response received successfully",
    #   "chunk_info_report" => [
    #     {
    #       "chunk_id" => 0,
    #       "chunk_checksum" => "test-response-checksum-0",
    #       "is_last_chunk" => false
    #     },
    #     {
    #       "chunk_id" => 1,
    #       "chunk_checksum" => "test-response-checksum-1",
    #       "is_last_chunk" => false
    #     },
    #     {
    #       "chunk_id" => 2,
    #       "chunk_checksum" => "test-response-checksum-2",
    #       "is_last_chunk" => true
    #     },
    #   ],
    #   "chunk_success" => [true, true, true]
    # }
  end

  def handle_send_chunks_request(send_chunks_request)
  end
end
