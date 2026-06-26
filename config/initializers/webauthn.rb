WebAuthn.configure do |config|
  config.allowed_origins = ["http://localhost:3000"]
  config.rp_name = "Rails WebAuthn Example"
end
