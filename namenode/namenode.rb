require 'grpc'
require 'toml-rb'
require_relative 'namenode_core_server'
require_relative 'namenode_data_server'

class HDFSNameNode
  attr_reader :server_name 
  attr_reader :server_ordinal
  attr_reader :is_primary
  attr_reader :server_config
  attr_reader :server

	def initialize(hostname="localhost", ordinal=0)
    # Load identification
		@server_name = hostname + ordinal.to_s
		@server_ordinal = @server_name.split('-').last.to_i

    # Primary namenode status
		if @server_ordinal == 0
			@is_primary = true
		else
			@is_primary = false
		end

    # Load configuration
    @server_config = TomlRB.load_file("./sim_config.toml")
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
    @server.handle(NameNodeCoreServer)
    @server.handle(NameNodeDataServer)
    @server.run_till_terminated
  end
end
