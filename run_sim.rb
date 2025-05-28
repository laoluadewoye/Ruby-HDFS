require './namenode/namenode-server'

# Create a test server
test_server = HDFSNameNodeServer.new

puts test_server.server_name
puts test_server.server_ordinal

test_node = test_server.server_name_node
puts test_node.is_primary_namenode
puts test_node.node_settings
