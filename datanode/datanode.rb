require 'grpc'
require 'toml-rb'
require 'pathname'
require_relative 'datanode_core_service'
require_relative 'datanode_data_service'
require_relative 'datanode_logic'

class HDFSDataNode
	attr_reader :datanode_hostname 
  attr_reader :datanode_ordinal
  attr_reader :datanode_config
  attr_reader :datanode_info
  attr_reader :datanode_server

  def initialize()
    # Load identification
    @datanode_hostname = ENV['HOSTNAME'] || "localhost-0"
		@datanode_ordinal = @datanode_hostname.split('-').last.to_i()

    # Load configuration
    @datanode_config = TomlRB.load_file("./sim_config.toml")

    # Search for an already saved node state.
    prior_node_state = load_prior_node_state(
      @datanode_config["nodeconfig"]["node_state_filename"],
      @datanode_config["nodeconfig"]["shared_fs_location"],
      @datanode_config["nodeconfig"]["data_location"],
      @datanode_hostname
    )

    if prior_node_state.nil?
      @datanode_info = create_new_node_state(
        @datanode_config["cluster"]["datanode_storage_size"],
        @datanode_config["cluster"]["datanode_storage_size_unit"],
        @datanode_config["block"]["block_size"],
        @datanode_config["block"]["block_size_unit"]
      )
    else
      @datanode_info = prior_node_state["datanode_info"]
    end

    # Load gRPC services and server
    @core_service = DataNodeCoreService.new(self)
    @data_service = DataNodeDataService.new(self)
    @datanode_server = create_server()
	end

  def create_server()
    # Create socket address
    ip_addr = @datanode_config["network"]["hdfs_listen_addr"]
    port = @datanode_config["network"]["hdfs_listen_port"]
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
    @datanode_server.run_till_terminated()
  end

  def handle_create_blocks_request(create_blocks_request)
  end

  def handle_retrieve_blocks_request(retrieve_blocks_request)
  end

  def handle_update_blocks_request(update_blocks_request)
  end

  def handle_delete_blocks_request(delete_blocks_request)
  end

  def handle_status_request(status_request)
  end

  def handle_received_chunk(chunk_data)
  end

  def create_receive_chunks_response(session_info)
    return test_receive_chunks_response()
  end

  def handle_send_chunks_request(send_chunks_request)
  end
end
