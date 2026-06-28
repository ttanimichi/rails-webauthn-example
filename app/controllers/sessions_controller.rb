class SessionsController < ApplicationController
  skip_before_action :require_login, only: :new

  def new
  end

  def destroy
    reset_session
    redirect_to new_session_path
  end
end
