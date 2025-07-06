def load_prior_node_state(node_state_filename, shared_fs_location, data_location, datanode_hostname)
  node_state_fps = [
    "#{shared_fs_location}/#{datanode_hostname}/#{node_state_filename}",
    "#{data_location}/#{node_state_filename}"
  ]

  prior_node_state = nil

  node_state_fps.each do |node_state_fp|
    begin
      prior_node_state = TomlRB.load_file(node_state_fp)
      break
    rescue Errno::ENOENT => e
      warn "Could not find TOML file at #{node_state_fp}: #{e.message}"
    rescue TomlRB::ParseError => e
      warn "Error parsing TOML file at #{node_state_fp}: #{e.message}"
    end
  end

  return prior_node_state
end

def create_new_node_state(storage_size, storage_size_unit, block_size, block_size_unit)
  # Load other parameters
  true_storage_size = storage_size * size_multiplier_table(storage_size_unit)
  true_block_size = block_size * size_multiplier_table(block_size_unit)

  block_count = (true_storage_size.to_f() / true_block_size).floor

  return {
    "time_started" => Time.now(),
    "times_recreated" => 0,
    "active_sessions" => 0,
    "workload_score" => 0,
    "total_blocks" => block_count,
    "used_blocks" => 0
  }
end

def size_multiplier_table(unit)
  case unit
  when "b"
    return 1
  when "kb"
    return 1024
  when "mb"
    return 1024 * 1024 # Or 1024**2
  when "gb"
    return 1024 * 1024 * 1024 # Or 1024**3
  else
    raise ArgumentError, "Unknown unit: #{unit}. Supported units are 'b', 'kb', 'mb', 'gb'."
  end
end

def test_receive_chunks_response()
  return {
    "response_success" => true,
    "response_message" => "Test response received successfully",
    "chunk_info_report" => [
      {
        "chunk_id" => 0,
        "chunk_checksum" => "test-response-checksum-0",
        "is_last_chunk" => false
      },
      {
        "chunk_id" => 1,
        "chunk_checksum" => "test-response-checksum-1",
        "is_last_chunk" => false
      },
      {
        "chunk_id" => 2,
        "chunk_checksum" => "test-response-checksum-2",
        "is_last_chunk" => true
      },
    ],
    "chunk_success" => [true, true, true]
  }
end
