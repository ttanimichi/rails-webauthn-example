class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  before_action :require_login

  helper_method :current_user, :current_webauthn_metadata

  private

  def current_user
    @current_user ||= User.find_by(id: session[:user_id])
  end

  def sign_in(user)
    session[:user_id] = user.id
    @current_user = user
  end

  def current_webauthn_metadata
    session[:webauthn_metadata] || {}
  end

  def store_webauthn_metadata(webauthn_credential)
    response = webauthn_credential.response

    session[:webauthn_metadata] = {
      aaguid: response.respond_to?(:aaguid) ? response.aaguid : nil,
      authenticator_attachment: webauthn_credential.authenticator_attachment,
      transports: response.respond_to?(:transports) ? response.transports : nil,
      backup_eligible: webauthn_credential.backup_eligible?,
      backed_up: webauthn_credential.backed_up?
    }.compact
  end

  def require_login
    redirect_to new_session_path unless current_user
  end
end
