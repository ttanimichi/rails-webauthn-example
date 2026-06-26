class User < ApplicationRecord
  has_many :webauthn_credentials, dependent: :destroy

  # User Handle を Base64URL でエンコードして保存している
  # A user handle is an opaque byte sequence with a maximum size of 64 bytes, and is not meant to be displayed to the user.
  # ref. https://www.w3.org/TR/webauthn-2/#user-handle
  validates :webauthn_user_handle, format: { with: /\A[A-Za-z0-9_-]+\z/ }, allow_nil: true
end
