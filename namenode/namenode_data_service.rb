require 'grpc'
require_relative '../hdfs_grpc/services/chunk_transfer_services_pb'

class NameNodeDataService < Chunktransfer::ChunkTransferService::Service
  def initialize(parent)
    @parent = parent
  end
  
  def receive_chunks(call)
    session_info = nil

    # Handle stream in parent class
    call.each_remote_read do |chunk_data|
      session_info = chunk_data["session_info"]
      @parent.handle_received_chunk(chunk_data)
    end

    # Create response objects
    new_response = @parent.create_receive_chunks_response(session_info)
    new_response_info = ResponseInfo.new(
      response_success: new_response["response_success"],
      response_message: new_response["response_message"],
    )
    new_chunk_info_report = []
    new_response["chunk_info_report"].each do |chunk_info|
      new_chunk_info_report << Chunktransfer::ChunkInfo.new(
        chunk_id: chunk_info["chunk_id"],
        chunk_checksum: chunk_info["chunk_checksum"],
        is_last_chunk: chunk_info["is_last_chunk"]
      )
    end

    # Return response
    return Chunktransfer::ReceiveChunksResponse.new(
      response_info: new_response_info,
      chunk_info_report: new_chunk_info_report,
      chunk_success: new_response["chunk_success"]
    )
  end

  def send_chunks(send_chunks_request, _call)
    # Get a list of chunk data
    chunk_data_list = @parent.handle_send_chunks_request(send_chunks_request)

    # Yield chunks to requester
    chunk_data_list.each do |chunk_data|
      new_session_info = SessionInfo.new(
        session_id: chunk_data["session_id"],
        session_checksum: chunk_data["session_checksum"]
      )
      new_chunk_info = Chunktransfer::ChunkInfo.new(
        chunk_id: chunk_data["chunk_id"],
        chunk_checksum: chunk_data["chunk_checksum"],
        is_last_chunk: chunk_data["is_last_chunk"]
      )
      yield Chunktransfer::ChunkData.new(
        session_info: new_session_info,
        chunk_info: new_chunk_info,
        chunk_data: chunk_data["chunk_data"]
      )
    end
  end
end
