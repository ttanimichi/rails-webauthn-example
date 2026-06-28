class WebauthnSessionsController < ApplicationController
  skip_before_action :require_login

  # Credential Authentication: Verification phase
  def create
    challenge = session.delete(:authentication_challenge)
    unless challenge
      render_authentication_error
      return
    end

    webauthn_credential = WebAuthn::Credential.from_get(authentication_params)
    unless webauthn_credential.user_handle
      render_authentication_error
      return
    end

    user = User.find_by!(webauthn_user_handle: webauthn_credential.user_handle)
    stored_credential = user.webauthn_credentials.find_by!(credential_id: webauthn_credential.id)

    webauthn_credential.verify(
      challenge,
      public_key: stored_credential.public_key,
      sign_count: stored_credential.sign_count,
      user_verification: true
    )

    stored_credential.update!(sign_count: webauthn_credential.sign_count)

    reset_session
    sign_in(user)

    head :no_content

  rescue WebAuthn::SignCountVerificationError => error
    # Cryptographic verification of the authenticator data には成功したが、署名カウンターが保存済みの値以下だった
    # これには複数の原因が考えられ、リスク許容度に応じて認証を失敗させるか成功とみなすかを選択できる
    # ref. https://www.w3.org/TR/webauthn-3/#sctn-sign-counter
    Rails.logger.warn("WebAuthn signature counter verification failed: #{error.message}")

  rescue WebAuthn::Error, ActiveRecord::RecordNotFound, ActiveRecord::RecordInvalid
    render_authentication_error
  end

  # Credential Authentication: Initiation phase
  def options
    # PublicKeyCredentialRequestOptions
    # ref. https://developer.mozilla.org/en-US/docs/Web/API/PublicKeyCredentialRequestOptions
    request_options = WebAuthn::Credential.options_for_get(user_verification: "required")
    session[:authentication_challenge] = request_options.challenge

    render json: request_options
  end

  private

  def authentication_params
    params.expect(credential: {}).to_h
  end

  def render_authentication_error
    render json: { error: "Passkey authentication failed." }, status: :unprocessable_entity
  end
end
