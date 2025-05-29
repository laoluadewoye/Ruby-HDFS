#!/bin/bash

if [ $# -eq 1 ]; then
  proto_file=$1
else
  echo "Please provide a single .proto file as an argument"
  exit 1
fi

grpc_tools_ruby_protoc --ruby_out=./client/lib --grpc_out=./client/lib $proto_file
grpc_tools_ruby_protoc --ruby_out=./server/lib --grpc_out=./server/lib $proto_file