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
		@node_settings = settings
	end
end

# Files should have metadata information and should be saved as json for offline storage
# Logs aplenty
# Should be sending signals of how free they are to do tasks
