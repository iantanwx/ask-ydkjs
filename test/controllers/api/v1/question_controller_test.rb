require "test_helper"

class Api::V1::QuestionControllerTest < ActionDispatch::IntegrationTest
  test "should get create" do
    get api_v1_question_create_url
    assert_response :success
  end
end
