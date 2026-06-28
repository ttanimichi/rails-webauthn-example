class WebauthnCredentialsController < ApplicationController
  # Credential Registration: Verification phase
  def create
    challenge = session.delete(:creation_challenge)
    unless challenge
      render json: { error: "Registration challenge is missing." }, status: :unprocessable_entity
      return
    end

    webauthn_credential = WebAuthn::Credential.from_create(create_params)
    webauthn_credential.verify(challenge, user_verification: true)

    current_user.webauthn_credentials.create!(
      credential_id: webauthn_credential.id,
      public_key: webauthn_credential.public_key,
      sign_count: webauthn_credential.sign_count
    )

    head :created
  rescue WebAuthn::Error, ActiveRecord::RecordInvalid => error
    render json: { error: error.message }, status: :unprocessable_entity
  end

  # Credential Registration: Initiation phase
  def options
    current_user.update!(webauthn_user_handle: WebAuthn.generate_user_id) unless current_user.webauthn_user_handle?

    # PublicKeyCredentialCreationOptions
    # ref. https://developer.mozilla.org/en-US/docs/Web/API/PublicKeyCredentialCreationOptions
    creation_options = WebAuthn::Credential.options_for_create(
      user: { id: current_user.webauthn_user_handle, name: current_user.name },
      exclude: current_user.webauthn_credentials.pluck(:credential_id),
      # Authenticator Selection Criteria
      # ref. https://www.w3.org/TR/webauthn-3/#dictdef-authenticatorselectioncriteria
      authenticator_selection: {
        resident_key: "required",
        user_verification: "required"
      }
    )

    session[:creation_challenge] = creation_options.challenge

    render json: creation_options
  end

  private

  def create_params
    params.expect(credential: {}).to_h
  end
end
