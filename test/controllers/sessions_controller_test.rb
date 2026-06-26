require "test_helper"

class SessionsControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get new_session_url
    assert_response :success
  end

  test "should post create" do
    post session_url
    assert_response :success
  end

  test "should redirect destroy without current user" do
    delete session_url

    assert_redirected_to new_session_url
  end
end
