require "rails_helper"

RSpec.describe "Comments", type: :request do
  describe "POST /tickets/:ticket_id/comments" do
    it "allows resident to comment on ticket from linked unit" do
      resident = create(:user, :resident)
      unit = create(:unit)
      create(:user_unit, user: resident, unit: unit)
      ticket = create(:ticket, user: resident, unit: unit)

      sign_in resident

      expect do
        post ticket_comments_path(ticket), params: {
          comment: { body: "Comentário do morador" }
        }
      end.to change(Comment, :count).by(1)

      expect(response).to redirect_to(ticket_path(ticket))
    end

    it "does not allow resident to comment outside linked units" do
      resident = create(:user, :resident)
      foreign_ticket = create(:ticket)

      sign_in resident

      expect do
        post ticket_comments_path(foreign_ticket), params: {
          comment: { body: "Tentativa sem escopo" }
        }
      end.not_to change(Comment, :count)

      expect(response).to redirect_to(tickets_path)
    end

    it "allows collaborator to comment inside assigned ticket-type scope" do
      collaborator = create(:user, :collaborator)
      assigned_type = create(:ticket_type)
      create(:user_ticket_type, user: collaborator, ticket_type: assigned_type)
      ticket = create(:ticket, ticket_type: assigned_type)

      sign_in collaborator

      expect do
        post ticket_comments_path(ticket), params: {
          comment: { body: "Comentário do colaborador" }
        }
      end.to change(Comment, :count).by(1)

      expect(response).to redirect_to(ticket_path(ticket))
    end
  end
end