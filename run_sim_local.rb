require_relative './namenode/namenode_server'

# Create a test server
test_server = HDFSNameNodeService.new

# Print out information
puts test_server.server_name
puts test_server.server_ordinal
puts test_server.server_config

test_node = test_server.server_name_node
puts test_node.is_primary_namenode

# Start the server
test_server.start_server()
