require "rails_helper"

RSpec.describe "Admin catalogs", type: :request do
  describe "POST /ticket_types" do
    it "allows admin to create ticket type" do
      admin = create(:user, :administrator)
      sign_in admin

      expect do
        post ticket_types_path, params: {
          ticket_type: {
            title: "Elétrica",
            sla_hours: 12
          }
        }
      end.to change(TicketType, :count).by(1)

      expect(response).to redirect_to(ticket_types_path)
    end

    it "does not allow collaborator to create ticket type" do
      collaborator = create(:user, :collaborator)
      sign_in collaborator

      expect do
        post ticket_types_path, params: {
          ticket_type: {
            title: "Hidráulica",
            sla_hours: 24
          }
        }
      end.not_to change(TicketType, :count)

      expect(response).to redirect_to(tickets_path)
    end
  end

  describe "POST /ticket_statuses" do
    it "allows admin to create ticket status" do
      admin = create(:user, :administrator)
      sign_in admin

      expect do
        post ticket_statuses_path, params: {
          ticket_status: {
            name: "Aguardando material",
            is_default: false,
            is_final: false
          }
        }
      end.to change(TicketStatus, :count).by(1)

      expect(response).to redirect_to(ticket_statuses_path)
    end

    it "does not allow resident to create ticket status" do
      resident = create(:user, :resident)
      sign_in resident

      expect do
        post ticket_statuses_path, params: {
          ticket_status: {
            name: "Indevido",
            is_default: false,
            is_final: false
          }
        }
      end.not_to change(TicketStatus, :count)

      expect(response).to redirect_to(tickets_path)
    end
  end
end