class HDFSInterface
	attr_accessor :name_nodes, :data_nodes
end

test_interface = HDFSInterface.new()
puts test_interface

# Should have load balancing somewhere
# Should have a secure registration method somewhere, maybe generating kubernetes keys