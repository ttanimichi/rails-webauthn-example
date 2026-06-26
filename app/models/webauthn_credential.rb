class WebauthnCredential < ApplicationRecord
  belongs_to :user

  # Credential ID
  # ref. https://www.w3.org/TR/webauthn-2/#credential-id
  validates :credential_id, presence: true, uniqueness: true

  # Credential Public Key
  # ref. https://www.w3.org/TR/webauthn-2/#credential-public-key
  validates :public_key, presence: true

  # Signature Counter
  # ref. https://www.w3.org/TR/webauthn-2/#sctn-sign-counter
  validates :sign_count, numericality: { greater_than_or_equal_to: 0 }
end
