require 'grpc'
require_relative '../hdfs_grpc/services/namenode_services_pb'

class NameNodeCoreServer < Namenode::NameNodeService::Service
  def name_node_alive(request, _call)
  end

  def data_node_alive(request, _call)
  end

  def interface_create_file(request, _call)
  end

  def interface_retrieve_file(request, _call)
  end

  def interface_update_file(request, _call)
  end

  def interface_delete_file(request, _call)
  end
end
