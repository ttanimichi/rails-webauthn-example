class SessionsController < ApplicationController
  skip_before_action :require_login, only: %i[new create]

  def new
  end

  def create
    user = User.find_or_create_by!(name: params.require(:name))
    session[:user_id] = user.id

    redirect_to root_path
  rescue ActiveRecord::RecordInvalid => error
    redirect_to new_session_path, alert: error.record.errors.full_messages.to_sentence
  end

  def destroy
    reset_session
    redirect_to new_session_path
  end
end
