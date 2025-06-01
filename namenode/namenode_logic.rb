# I lied again, this is where the functional stuff will be.

# Files should have metadata information and should be saved as json for offline storage
# Logs aplenty
# Should be sending signals of how free they are to do tasks

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
