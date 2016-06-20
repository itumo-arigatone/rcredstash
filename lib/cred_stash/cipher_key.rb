class CredStash::CipherKey
  attr_reader :data_key, :hmac_key, :wrapped_key

  def self.generate(client: Aws::KMS::Client.new)
    res = client.generate_data_key(key_id: 'alias/credstash', number_of_bytes: 64)
    new(
      data_key: res.plaintext[0...32],
      hmac_key: res.plaintext[32..-1],
      wrapped_key: res.ciphertext_blob
    )
  end

  def self.decrypt(wrapped_key, client: Aws::KMS::Client.new)
    res = client.decrypt(ciphertext_blob: wrapped_key)
    new(
      data_key: res.plaintext[0...32],
      hmac_key: res.plaintext[32..-1],
      wrapped_key: wrapped_key
    )
  end

  def initialize(data_key:, hmac_key:, wrapped_key:)
    @data_key = data_key
    @hmac_key = hmac_key
    @wrapped_key = wrapped_key
  end

  def hmac(message)
    OpenSSL::HMAC.hexdigest("SHA256", hmac_key, message)
  end
end
