require 'grpc'
require_relative './namenode/namenode'
require_relative './datanode/datanode'
require_relative './hdfs_grpc/services/chunk_transfer_services_pb'

# Create a test namenode server
test_node = HDFSNameNode.new()

# Print out information
puts test_node.namenode_name
puts test_node.namenode_ordinal
puts test_node.is_primary
puts test_node.namenode_config

# # Create a test datanode server
# test_node = HDFSDataNode.new()

# # Print out information
# puts test_node.datanode_name
# puts test_node.datanode_ordinal
# puts test_node.datanode_config

# Start the server
server_thread = Thread.new { test_node.start_server() }

# Create a client connection to the server
credentials = GRPC::Core::ChannelCredentials.new(
  File.read("./hdfs_setup/tls/simulation-ca-server.crt"),
  File.read("./hdfs_setup/tls/interface-server.key"),
  File.read("./hdfs_setup/tls/interface-server.crt")
)
server_conn = Chunktransfer::ChunkTransferService::Stub.new("localhost:11738", credentials)

# Create a list of test chunks to send
test_chunk_list = []
for i in 0..3 do
  test_chunk = "This is a test chunk data " + i.to_s()
  test_chunk_list << Chunktransfer::ChunkData.new(
    session_info: SessionInfo.new(
      session_id: "test-session",
      session_checksum: "test-checksum"
    ),
    chunk_info: Chunktransfer::ChunkInfo.new(
      chunk_id: i,
      chunk_checksum: "test-chunk-checksum-" + i.to_s(),
      is_last_chunk: (i == 100)
    ),
    chunk_data: test_chunk.encode('UTF-8')
  )
end

# Send the chunks to the server
response = server_conn.receive_chunks(test_chunk_list.each)

# Kill the server thread
Thread.kill(server_thread)
puts response
