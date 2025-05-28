require 'toml-rb'

# HDFS configuration struct
HDFSConfig = Struct.new(
	:heartbeat_interval_secs,
	:heartbeat_timeout_secs,
	:interface_port, 
	:hdfs_port, 
	:block_size, 
	:block_size_unit, 
	:file_replication_count,
	:file_hash_function,
	:file_checksum_method
)

# HDFS NameNode class
class HDFSNameNode
	attr_accessor :node_name, :node_id, :is_primary_namenode

	def initialize(name, id)
		# Identification
		@node_name = name
		@node_id = id

		# Primary namenode status
		if id == 0
			@is_primary_namenode = true
		else
			@is_primary_namenode = false
		end
	end
end

test_node = HDFSNameNode.new("testnode", 0)

puts test_node.node_name
puts test_node.node_id
puts test_node.is_primary_namenode

raw_config = TomlRB.load_file("D:/Coding Stuff/Ruby Projects/Hadoop Simulation/sim_config.toml")
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

puts struct_config

# Files should have metadata information and should be saved as json for offline storage
# Logs aplenty
# Should be sending signals of how free they are to do tasks
