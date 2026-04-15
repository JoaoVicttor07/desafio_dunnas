require "rails_helper"

RSpec.describe TicketStatus, type: :model do
  it "allows only one default status" do
    create(:ticket_status, :opened_default)
    duplicate_default = build(:ticket_status, name: "Outro padrão", is_default: true)

    expect(duplicate_default).not_to be_valid
    expect(duplicate_default.errors[:is_default]).to include("já existe um status padrão")
  end
end
