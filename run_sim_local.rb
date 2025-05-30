require 'grpc'
require_relative './namenode/namenode_server'
require_relative './hdfs_grpc/services/namenode_services_pb'

# Create a test server
test_server = HDFSNameNodeService.new

# Print out information
puts test_server.server_name
puts test_server.server_ordinal
puts test_server.server_config

test_node = test_server.server_name_node
puts test_node.is_primary_namenode

# Start the server
server_thread = Thread.new { test_server.start_server() }

# Try calling it
# credentials = GRPC::Core::ChannelCredentials.new(
#   File.read("./hdfs_setup/tls/datanode-0-server.crt"),
#   File.read("./hdfs_setup/tls/datanode-1-server.key"),
#   File.read("./hdfs_setup/tls/datanode-1-server.crt")
# )
# client = Namenode::NameNodeService::Stub.new('datanode-0:11738', credentials)
# response = client.retrieve_file(Namenode::RetrieveFileRequest.new)
# Thread.kill(server_thread)
