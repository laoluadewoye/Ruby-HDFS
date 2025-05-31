require 'grpc'
require_relative '../hdfs_grpc/services/chunk_transfer_services_pb'

class NameNodeDataServer < Chunktransfer::ChunkTransferService::Service
  def initialize(parent)
    @parent = parent
  end
  
  def receive_chunks(chunk_data)
  end

  def send_chunks(request, _call)
  end
end
