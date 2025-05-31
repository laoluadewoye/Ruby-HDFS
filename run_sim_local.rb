require 'grpc'
require_relative './namenode/namenode'
require_relative './hdfs_grpc/services/namenode_services_pb'

# Create a test server
test_node = HDFSNameNode.new

# Print out information
puts test_node.server_name
puts test_node.server_ordinal
puts test_node.is_primary
puts test_node.server_config

# Start the server
server_thread = Thread.new { test_node.start_server() }

# # Try calling it
# credentials = GRPC::Core::ChannelCredentials.new(
#   File.read("./hdfs_setup/tls/datanode-0-server.crt"),
#   File.read("./hdfs_setup/tls/datanode-1-server.key"),
#   File.read("./hdfs_setup/tls/datanode-1-server.crt")
# )
# client = Namenode::NameNodeService::Stub.new('datanode-0:11738', credentials)
# response = client.name_node_alive(Namenode::NameNodePing.new)

Thread.kill(server_thread)
