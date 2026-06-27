class WebauthnCredentialsController < ApplicationController
  def options
    current_user.update!(webauthn_user_handle: WebAuthn.generate_user_id) unless current_user.webauthn_user_handle?

    options = WebAuthn::Credential.options_for_create(
      user: { id: current_user.webauthn_user_handle, name: current_user.name },
      exclude: current_user.webauthn_credentials.pluck(:credential_id),
      # Authenticator Selection Criteria
      # ref. https://www.w3.org/TR/webauthn-3/#dictdef-authenticatorselectioncriteria
      authenticator_selection: {
        resident_key: "required",
        user_verification: "required"
      }
    )

    session[:creation_challenge] = options.challenge

    render json: options
  end
end
