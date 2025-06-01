require 'grpc'
require_relative '../hdfs_grpc/services/namenode_services_pb'

class NameNodeCoreService < Namenode::NameNodeService::Service
  def initialize(parent)
    @parent = parent
  end
  
  def name_node_alive(name_node_ping, _call)
    response = @parent.handle_name_node_ping(name_node_ping)
    return Namenode::NameNodePingResponse.new(
      response_info: ResponseInfo.new(
        response_success: response["success"],
        response_message: response["message"],
      ),
      node_telemetry: NodeTelemetry.new(
        time_stamp: response["time_stamp"],
        active_threads: response["active_threads"],
        active_conns: response["active_conns"]
      )
    )
  end

  def data_node_alive(data_node_ping, _call)
    response = @parent.handle_data_node_ping(data_node_ping)
    return Namenode::DataNodePingResponse.new(
      response_info: ResponseInfo.new(
        response_success: response["success"],
        response_message: response["message"],
      ),
      node_telemetry: NodeTelemetry.new(
        time_stamp: response["time_stamp"],
        active_threads: response["active_threads"],
        active_conns: response["active_conns"]
      )
    )
  end

  def interface_create_file(create_file_request, _call)
    response = @parent.handle_create_file_request(create_file_request)

    # Create session info list
    sesssion_info_list = []
    response["session_info_list"].each do |session_info|
      sesssion_info_list << SessionInfo.new(
        session_id: session_info["session_id"],
        session_checksum: session_info["session_checksum"]
      )
    end

    return Namenode::CreateFileResponse.new(
      response_info: ResponseInfo.new(
        response_success: response["success"],
        response_message: response["message"],
      ),
      session_info_list: sesssion_info_list
    )
  end

  def interface_retrieve_file(retrieve_file_request, _call)
    response = @parent.handle_retrieve_file_request(retrieve_file_request)
    return Namenode::RetrieveFileResponse.new(
      response_info: ResponseInfo.new(
        response_success: response["success"],
        response_message: response["message"]
      ),
      session_info: SessionInfo.new(
        session_id: response["session_id"],
        session_checksum: response["session_checksum"]
      )
    )
  end

  def interface_update_file(update_file_request, _call)
    response = @parent.handle_update_file_request(update_file_request)

    # Create session info list
    sesssion_info_list = []
    response["session_info_list"].each do |session_info|
      sesssion_info_list << SessionInfo.new(
        session_id: session_info["session_id"],
        session_checksum: session_info["session_checksum"]
      )
    end

    return Namenode::UpdateFileResponse.new(
      response_info: ResponseInfo.new(
        response_success: response["success"],
        response_message: response["message"],
      ),
      session_info_list: sesssion_info_list
    )
  end

  def interface_delete_file(delete_file_request, _call)
    response = @parent.handle_delete_file_request(delete_file_request)
    return Namenode::DeleteFileResponse.new(
      response_info: ResponseInfo.new(
        response_success: response["success"],
        response_message: response["message"]
      )
    )
  end
end
