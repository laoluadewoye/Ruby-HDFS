require 'toml-rb'
require 'openssl'
require 'fileutils'

# Load configuration
$sim_config = TomlRB.load_file("./sim_config.toml")

def create_key_cert(common_name, service_name=nil, ca_cert=nil, ca_key=nil)
  puts "Creating TLS key and certificate for #{common_name}..."

  # Generate a new RSA private key
  key = OpenSSL::PKey::RSA.new($sim_config["security"]["tls_rsa_key_size"])

  # Create a new certificate
  cert = OpenSSL::X509::Certificate.new()
  cert.version = $sim_config["security"]["tls_cert_version"]
  cert.serial = OpenSSL::BN.rand(
    $sim_config["security"]["tls_cert_serial_length"]
  )
  cert.public_key = key.public_key

  # Set the subject and issuer of the certificate
  if service_name.nil?
    subject_str = "/DC=simulation/CN=#{common_name}"
  else
    subject_str = "/DC=simulation/DC=#{service_name}/CN=#{common_name}"
  end
  cert.subject = OpenSSL::X509::Name.parse(subject_str)
  cert.issuer = ca_cert.nil? ? cert.subject : ca_cert.subject

  # Set the validity period of the certificate
  period = $sim_config["security"]["tls_cert_validity_days"] * 24 * 60 * 60
  cert.not_before = Time.now()
  cert.not_after = cert.not_before + period

  # Add certificates to the certificate extentions
  extension_factory = OpenSSL::X509::ExtensionFactory.new()
  extension_factory.subject_certificate = cert
  extension_factory.issuer_certificate = ca_cert.nil? ? cert : ca_cert

  # Add CA constraint
  if ca_cert.nil?
    cert.add_extension(
      extension_factory.create_extension("basicConstraints", "CA:FALSE", true)
    )
  else
    cert.add_extension(
      extension_factory.create_extension("basicConstraints", "CA:TRUE", true)
    )
  end

  # Add other necessary extensions
  cert.add_extension(
    extension_factory.create_extension(
      "keyUsage", 
      "keyEncipherment,digitalSignature,keyCertSign,cRLSign,dataEncipherment",
      true
    )
  )
  cert.add_extension(
    extension_factory.create_extension("subjectKeyIdentifier", "hash", false)
  )
  cert.add_extension(
    extension_factory.create_extension(
      "authorityKeyIdentifier", "keyid:always,issuer:always", false
    )
  )

  # Sign the certificate with the private key
  hash = $sim_config["security"]["tls_cert_digest_hash"]
  if ca_key.nil?
    cert.sign(key, OpenSSL::Digest.new(hash))
  else
    cert.sign(ca_key, OpenSSL::Digest.new(hash))
  end

  # Save the key and cert to files
  setup_location = $sim_config["setup_location"] + "/tls"
  file_prefix = setup_location + "/" + common_name
  File.write("#{file_prefix}-server.key", key.private_to_pem)
  File.write("#{file_prefix}-server.crt", cert.to_pem)

  return key, cert
end

# Check if reset is enabled
if $sim_config["reset_persistent"]
  puts "Resetting persistent data..."
  # Remove the setup location if it exists
  if Dir.exist?($sim_config["setup_location"])
    FileUtils.rm_rf($sim_config["setup_location"])
  end
end

# Create setup folders if it doesn't exist
if !Dir.exist?($sim_config["setup_location"])
  puts "Creating folders..."
  Dir.mkdir($sim_config["setup_location"])  # Main
  Dir.mkdir($sim_config["setup_location"] + "/tls")  # TLS folder
end

# Create the TLS stuff if needed
if $sim_config["security"]["enable_tls"]
  # Create the CA key and certificate
  ca_key, ca_cert = create_key_cert("simulation-ca")

  # Create keys and certificates for the NameNodes
  for i in 1..$sim_config["nodecount"]["name_node_count"] do
    create_key_cert("namenode-" + (i-1).to_s, "namelayer-service", ca_cert, ca_key)
  end

  # Create keys and certificates for the DataNodes
  for i in 1..$sim_config["nodecount"]["data_node_count"] do
    create_key_cert("datanode-" + (i-1).to_s, "datalayer-service", ca_cert, ca_key)
  end

  # Create key and certificate for the Interface
  create_key_cert("interface", "interface-service", ca_cert, ca_key)
  
  # Create test keys and certificates
  create_key_cert("test-server", "test-service", ca_cert, ca_key)
  create_key_cert("test-client", "test-service", ca_cert, ca_key)
  create_key_cert("localhost", "test-service", ca_cert, ca_key)
  
  puts "TLS setup completed."
else
  puts "TLS is not enabled, skipping TLS setup."
end
