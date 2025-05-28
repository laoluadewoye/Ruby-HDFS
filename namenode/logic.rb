require 'toml-rb'

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

# Files should have metadata information and should be saved as json for offline storage
# Logs aplenty
# Should be sending signals of how free they are to do tasks