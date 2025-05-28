require 'toml-rb'
require './namenode/logic'

# Load the configuration file
raw_config = TomlRB.load_file("sim_config.toml")

# Create an instance of HDFSConfig using the loaded configuration
struct_config = HDFSConfig.new(
	raw_config["heartbeat_interval_secs"],
	raw_config["heartbeat_timeout_secs"],
	raw_config["interface_port"],
	raw_config["hdfs_port"],
	raw_config["block_size"],
	raw_config["block_size_unit"],
	raw_config["file_replication_count"],
	raw_config["file_hash_function"],
	raw_config["file_checksum_method"]
)

# Create a test namenode
test_node = HDFSNameNode.new("testnode", 0, struct_config)

puts test_node.node_name
puts test_node.node_id
puts test_node.is_primary_namenode
puts test_node.node_settings
