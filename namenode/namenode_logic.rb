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
	attr_accessor :node_name, :node_id, :is_primary_namenode, :node_settings

	def initialize(name, id, settings)
		# Identification
		@node_name = name
		@node_id = id

		# Primary namenode status
		if id == 0
			@is_primary_namenode = true
		else
			@is_primary_namenode = false
		end

		# Node settings
		@node_settings = create_settings_struct(settings)
	end

	def create_settings_struct(raw_config)
		return HDFSConfig.new(
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
	end
end

# Files should have metadata information and should be saved as json for offline storage
# Logs aplenty
# Should be sending signals of how free they are to do tasks
