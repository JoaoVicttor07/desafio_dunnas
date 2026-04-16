require "rails_helper"

RSpec.describe "Admin::AuditLogs", type: :request do
  describe "GET /admin/audit_logs" do
    it "allows administrators to view and filter logs" do
      admin = create(:user, :administrator)
      create(:audit_log, actor: admin, action: "ticket.created")
      create(:audit_log, actor: admin, action: "ticket.updated")

      sign_in admin

      get admin_audit_logs_path, params: { audit_action: "ticket.created" }

      expect(response).to have_http_status(:ok)
      table_body = response.body[/<tbody[^>]*>(.*?)<\/tbody>/m, 1]

      expect(table_body).to include("Chamado criado")
      expect(table_body).not_to include("Chamado atualizado")
    end

    it "shows an alert when end date is before start date" do
      admin = create(:user, :administrator)
      create(:audit_log, actor: admin, action: "ticket.created")

      sign_in admin

      get admin_audit_logs_path, params: { from: "2026-04-15", to: "2026-04-10" }

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Não é possível filtrar uma data final antes da data inicial.")
      expect(response.body).to include("Chamado criado")
    end

    it "denies non-admin users" do
      collaborator = create(:user, :collaborator)

      sign_in collaborator
      get admin_audit_logs_path

      expect(response).to redirect_to(tickets_path)
    end
  end

  describe "GET /admin/audit_logs/:id" do
    it "shows details to administrators" do
      admin = create(:user, :administrator)
      log = create(:audit_log, actor: admin, action: "comment.created")

      sign_in admin
      get admin_audit_log_path(log)

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Comentario criado")
    end
  end
end