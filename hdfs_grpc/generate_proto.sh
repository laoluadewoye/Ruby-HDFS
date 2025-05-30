#!/bin/bash

# Get the directory where the script resides
script_dir="$(dirname "${BASH_SOURCE[0]}")"

# Set directory-specific variables
definitions_dir="$script_dir/definitions"
services_dir="$script_dir/services"
replace_script="$script_dir/replace_require.rb"

# Create the services directory if it doesn't exist
mkdir -p "$services_dir"

# Get all definition files in the protocol definitions directory
proto_files=($(ls $definitions_dir | grep ".proto"))

# Loop through each file
for proto_file in "${proto_files[@]}"; do
  echo "Processing $proto_file..."

  # Check if the file already has service files generated
  proto_base="${proto_file%.*}"
  matching_services=($(ls $services_dir | grep "$proto_base"))
  
  # If so check if they are outdated
  outdated_services=0
  if [ ${#matching_services[@]} -gt 0 ]; then
	for service_file in "${matching_services[@]}"; do
	  # If the .proto file is newer, mark the services as outdated
	  if [ "$definitions_dir/$proto_file" -nt "$services_dir/$service_file" ]; then
		outdated_services=1
		echo "Outdated service file found: $service_file"
		break
	  fi
	done
  fi
  
  # Check if existing services are outdated or do not exist
  if [ $outdated_services == 1 ] || [ ${#matching_services[@]} -eq 0 ]; then
	echo "Generating new protocol buffers for $proto_file..."

	# Generate Ruby gRPC code from the .proto file if needed
  	grpc_tools_ruby_protoc --proto_path=$definitions_dir \
	  --ruby_out=$services_dir \
	  --grpc_out=$services_dir \
	  "shared/core_messages.proto" \
	  $proto_file
	
	# Use a ruby script to adjust requirements in buffer files
	buffer_suffix="_pb.rb"
	proto_buffer_path="$services_dir/$proto_base$buffer_suffix"
	ruby $replace_script $proto_buffer_path

	services_suffix="_services_pb.rb"
	proto_services_path="$services_dir/$proto_base$services_suffix"
	ruby $replace_script $proto_services_path
  else
	echo "Service files for $proto_file are up to date."
  fi
done
