require 'toml-rb'
require 'openssl'
require 'fileutils'

# Load configuration
$sim_config = TomlRB.load_file("./sim_config.toml")

def create_key_cert(common_name)
  puts "Creating TLS key and certificate for #{common_name}..."

  # Generate a new RSA private key
  key = OpenSSL::PKey::RSA.new 2048

  # Create a new certificate
  cert = OpenSSL::X509::Certificate.new
  cert.version = 2
  cert.serial = OpenSSL::BN.rand(32)
  cert.subject = OpenSSL::X509::Name.parse "/CN=#{common_name}"
  cert.issuer = cert.subject
  cert.public_key = key.public_key

  # Set the validity period of the certificate
  period = $sim_config["security"]["tls_cert_validity_days"] * 24 * 60 * 60
  cert.not_before = Time.now
  cert.not_after = cert.not_before + period

  # Add extensions to the certificate
  extension_factory = OpenSSL::X509::ExtensionFactory.new
  extension_factory.subject_certificate = cert
  extension_factory.issuer_certificate = cert
  cert.add_extension(
    extension_factory.create_extension("basicConstraints", "CA:TRUE", true)
  )
  cert.add_extension(
    extension_factory.create_extension(
      "keyUsage", 
      "keyEncipherment, digitalSignature, keyCertSign, cRLSign", 
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
  cert.sign(key, OpenSSL::Digest.new('SHA256'))

  # Save the key and cert to files
  setup_location = $sim_config["general"]["setup_location"] + "/tls"
  file_prefix = setup_location + "/" + common_name
  File.write "#{file_prefix}-server.key", key.private_to_pem
  File.open("#{file_prefix}-server.crt", "wb") { |f| f.print cert.to_pem }
end

# Check if reset is enabled
if $sim_config["general"]["reset_persistent"]
  puts "Resetting persistent data..."
  # Remove the setup location if it exists
  if Dir.exist?($sim_config["general"]["setup_location"])
    FileUtils.rm_rf($sim_config["general"]["setup_location"])
  end
end

# Create setup folders if it doesn't exist
if !Dir.exist?($sim_config["general"]["setup_location"])
  puts "Creating folders..."
  Dir.mkdir($sim_config["general"]["setup_location"])  # Main
  Dir.mkdir($sim_config["general"]["setup_location"] + "/tls")  # TLS folder
end

# Create the TLS stuff if needed
if $sim_config["security"]["enable_tls"]
  # Create keys and certificates for the NameNodes
  for i in 1..$sim_config["kube"]["name_node_count"] do
    create_key_cert("namenode-" + (i-1).to_s)
  end

  # Create keys and certificates for the DataNodes
  for i in 1..$sim_config["kube"]["data_node_count"] do
    create_key_cert("datanode-" + (i-1).to_s)
  end

  # Create key and certificate for the Interface
  create_key_cert("interface")

  puts "TLS setup completed."
else
  puts "TLS is not enabled, skipping TLS setup."
end
