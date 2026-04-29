require "rails_helper"

RSpec.describe TicketStatus, type: :model do
  it "allows only one default status" do
    create(:ticket_status, :opened_default)
    duplicate_default = build(:ticket_status, name: "Outro padrão", is_default: true)

    expect(duplicate_default).not_to be_valid
    expect(duplicate_default.errors[:is_default]).to include("já existe um status padrão")
  end

  it "does not allow the default opened status to be final" do
    status = build(:ticket_status, name: "Aberto", is_default: true, is_final: true)

    expect(status).not_to be_valid
    expect(status.errors[:is_final]).to include("não pode ser marcado para o status Aberto")
  end

  it "allows only Aberto to be the default status" do
    status = build(:ticket_status, name: "Em andamento", is_default: true, is_final: false)

    expect(status).not_to be_valid
    expect(status.errors[:is_default]).to include("só pode ser marcado no status Aberto")
  end

  it "keeps Aberto marked as the default status" do
    status = build(:ticket_status, name: "Aberto", is_default: false, is_final: false)

    expect(status).not_to be_valid
    expect(status.errors[:is_default]).to include("deve permanecer marcado para o status Aberto")
  end
end
