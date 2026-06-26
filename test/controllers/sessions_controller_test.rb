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

  test "should delete destroy" do
    delete session_url
    assert_response :success
  end
end
