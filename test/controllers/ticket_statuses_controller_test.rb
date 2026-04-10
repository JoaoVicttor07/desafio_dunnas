require "test_helper"

class TicketStatusesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @ticket_status = ticket_statuses(:one)
  end

  test "should get index" do
    get ticket_statuses_url
    assert_response :success
  end

  test "should get new" do
    get new_ticket_status_url
    assert_response :success
  end

  test "should create ticket_status" do
    assert_difference("TicketStatus.count") do
      post ticket_statuses_url, params: { ticket_status: { is_default: @ticket_status.is_default, name: @ticket_status.name } }
    end

    assert_redirected_to ticket_status_url(TicketStatus.last)
  end

  test "should show ticket_status" do
    get ticket_status_url(@ticket_status)
    assert_response :success
  end

  test "should get edit" do
    get edit_ticket_status_url(@ticket_status)
    assert_response :success
  end

  test "should update ticket_status" do
    patch ticket_status_url(@ticket_status), params: { ticket_status: { is_default: @ticket_status.is_default, name: @ticket_status.name } }
    assert_redirected_to ticket_status_url(@ticket_status)
  end

  test "should destroy ticket_status" do
    assert_difference("TicketStatus.count", -1) do
      delete ticket_status_url(@ticket_status)
    end

    assert_redirected_to ticket_statuses_url
  end
end
