require 'grpc'
require_relative '../hdfs_grpc/services/datanode_services_pb.rb'

class DataNodeCoreService < Datanode::DataNodeService::Service
  def initialize(parent)
    @parent = parent
  end

  def name_node_create_blocks(create_blocks_request, _call)
	response = @parent.handle_create_blocks_request(create_blocks_request)

	# Create session info list
    sesssion_info_list = []
    response["session_info_list"].each do |session_info|
      sesssion_info_list << SessionInfo.new(
        session_id: session_info["session_id"],
        session_checksum: session_info["session_checksum"]
      )
    end

    return Datanode::CreateBlocksResponse.new(
      response_info: ResponseInfo.new(
        response_success: response["success"],
        response_message: response["message"],
      ),
      session_info_list: sesssion_info_list
    )
  end

  def name_node_retrieve_blocks(retrieve_blocks_request, _call)
	response = @parent.handle_retrieve_blocks_request(retrieve_blocks_request)

	# Create session info list
    sesssion_info_list = []
    response["session_info_list"].each do |session_info|
      sesssion_info_list << SessionInfo.new(
        session_id: session_info["session_id"],
        session_checksum: session_info["session_checksum"]
      )
    end

    return Datanode::RetrieveBlocksResponse.new(
      response_info: ResponseInfo.new(
        response_success: response["success"],
        response_message: response["message"],
      ),
      session_info_list: sesssion_info_list
    )
  end

  def name_node_update_blocks(update_blocks_request, _call)
	response = @parent.handle_update_blocks_request(update_blocks_request)

	# Create session info list
    sesssion_info_list = []
    response["session_info_list"].each do |session_info|
      sesssion_info_list << SessionInfo.new(
        session_id: session_info["session_id"],
        session_checksum: session_info["session_checksum"]
      )
    end

    return Datanode::UpdateBlocksResponse.new(
      response_info: ResponseInfo.new(
        response_success: response["success"],
        response_message: response["message"],
      ),
      session_info_list: sesssion_info_list
    )
  end

  def name_node_delete_blocks(delete_blocks_request, _call)
	response = @parent.handle_delete_blocks_request(delete_blocks_request)

	return Datanode::DeleteBlocksResponse.new(
	  response_info: ResponseInfo.new(
		response_success: response["success"],
		response_message: response["message"],
	  ),
	  deletion_status: response["deletion_status"]
	)
  end

  def name_node_status_request(status_request, _call)
	response = @parent.handle_status_request(status_request)

	return Datanode::StatusResponse.new(
	  response_info: ResponseInfo.new(
		response_success: response["success"],
		response_message: response["message"],
	  ),
	  node_telemetry: NodeTelemetry.new(
		time_stamp: response["time_stamp"],
		active_threads: response["active_threads"],
		active_conns: response["active_conns"]
	  ),
	  unused_blocks: response["unused_blocks"]
	)
  end
end
