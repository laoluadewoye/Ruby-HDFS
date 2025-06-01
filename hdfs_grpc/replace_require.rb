# Read file lines
file_path = ARGV[0]
lines = File.readlines(file_path, chomp: true)

# Alter lines containing "replace"
altered_lines = lines.map do |line|
  has_require = line.include?("require")
  has_require_relative = line.include?("require_relative")
  has_google = line.include?("google")
  has_grpc = line.include?("grpc")
  if has_require && !has_google && !has_grpc && !has_require_relative
    line.gsub("require", "require_relative")
  else
    line
  end
end

# Save back to file
File.open(file_path, "w") do |file|
  altered_lines.each do |line|
    file.puts(line)
  end
end
