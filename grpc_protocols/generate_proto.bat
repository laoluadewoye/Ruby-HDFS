@echo off

if "%1"=="" goto error
set proto_file=%1
goto generate_proto

:error
echo Please provide a single .proto file as an argument
pause
exit /b 1

:generate_proto
call grpc_tools_ruby_protoc --ruby_out=./client/lib --grpc_out=./client/lib %proto_file%
call grpc_tools_ruby_protoc --ruby_out=./server/lib --grpc_out=./server/lib %proto_file%