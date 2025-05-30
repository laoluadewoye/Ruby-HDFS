require 'toml-rb'
require 'securerandom'
require 'openssl'
require 'fileutils'

def create_key_cert(common_name, validity_days, setup_location)
  puts "Creating TLS key and certificate for #{common_name}..."

  # Generate a new RSA private key
  key = OpenSSL::PKey::RSA.new(2048)

  # Create a new certificate
  cert = OpenSSL::X509::Certificate.new

  # Set the version of the certificate
  cert.version = 3

  # Set the serial number (randomly generated)
  partial_serial = SecureRandom.random_bytes(16)
  cert.serial = OpenSSL::BN.new(partial_serial.unpack1('H*'), 16)
  
  # Set validity period
  cert.not_before = Time.now
  cert.not_after = cert.not_before + (validity_days * 24 * 60 * 60)

  # Set subject and issuer (self-signed)
  name = OpenSSL::X509::Name.parse("/CN=#{common_name}")
  cert.subject = name
  cert.issuer = name

  # Set public key
  cert.public_key = key.public_key

  # Add extensions (optional, e.g., for TLS)
  extension_factory = OpenSSL::X509::ExtensionFactory.new
  extension_factory.subject_certificate = cert
  extension_factory.issuer_certificate = cert

  cert.add_extension(extension_factory.create_extension("basicConstraints", "CA:TRUE", true))
  cert.add_extension(extension_factory.create_extension("subjectKeyIdentifier", "hash"))
  cert.add_extension(extension_factory.create_extension("authorityKeyIdentifier", "keyid:always,issuer:always"))

  # Sign the certificate with the key
  cert.sign(key, OpenSSL::Digest::SHA256.new)

  # Save the key and cert to files
  file_prefix = setup_location + "/" + common_name
  File.open("#{file_prefix}-server.key", "w") { |f| f.write(key.to_pem) }
  File.open("#{file_prefix}-server.crt", "w") { |f| f.write(cert.to_pem) }
end

# Load configuration
sim_config = TomlRB.load_file("./sim_config.toml")

# Check if reset is enabled
if sim_config["reset_persistent"]
  puts "Resetting persistent data..."
  # Remove the setup location if it exists
  if Dir.exist?(sim_config["setup_location"])
    FileUtils.rm_rf(sim_config["setup_location"])
  end
end

# Create setup folders if it doesn't exist
if !Dir.exist?(sim_config["setup_location"])
  puts "Creating folders..."
  Dir.mkdir(sim_config["setup_location"])  # Main
  Dir.mkdir(sim_config["setup_location"] + "/tls")  # TLS folder
end

# Create the TLS stuff if needed
if sim_config["enable_tls"]
  # Create keys and certificates for the NameNodes
  for i in 1..sim_config["name_node_count"] do
    create_key_cert(
      "namenode-" + (i-1).to_s,
      sim_config["tls_cert_validity_days"],
      sim_config["setup_location"] + "/tls"
    )
  end

  # Create keys and certificates for the DataNodes
  for i in 1..sim_config["data_node_count"] do
    create_key_cert(
      "datanode-" + (i-1).to_s,
      sim_config["tls_cert_validity_days"],
      sim_config["setup_location"] + "/tls"
    )
  end

  # Create key and certificate for the Interface
  create_key_cert(
    "interface",
    sim_config["tls_cert_validity_days"],
    sim_config["setup_location"] + "/tls"
  )

  puts "TLS setup completed."
else
  puts "TLS is not enabled, skipping TLS setup."
end
