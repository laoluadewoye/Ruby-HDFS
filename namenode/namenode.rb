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
		@namenode_name = hostname + ordinal.to_s
		@namenode_ordinal = @namenode_name.split('-').last.to_i

    # Primary namenode status
		if @namenode_ordinal == 0
			@is_primary = true
		else
			@is_primary = false
		end

    # Load configuration
    @namenode_config = TomlRB.load_file("./sim_config.toml")

    # Load gRPC servers
    @core_server = NameNodeCoreServer.new(self)
    @data_server = NameNodeDataServer.new(self)
    @namenode_server = create_server()
	end

  def create_server()
    # Create socket address
    ip_addr = @namenode_config["network"]["hdfs_listen_addr"]
    port = @namenode_config["network"]["hdfs_listen_port"]
    socket = ip_addr + ":" + port.to_s

    # Create the credentials
    key = File.read("./hdfs_setup/tls/datanode-0-server.key")
    cert = File.read("./hdfs_setup/tls/datanode-0-server.crt")
    credentials = GRPC::Core::ServerCredentials.new(
      nil, [{ private_key: key, cert_chain: cert }], true
    )

    # Create the server
    new_server = GRPC::RpcServer.new
    new_server.add_http2_port(socket, credentials)
    new_server.handle(@core_server)
    new_server.handle(@data_server)

    return new_server
  end

  def start_server()
    @namenode_server.run_till_terminated()
  end
end
