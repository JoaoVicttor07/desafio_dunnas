require "rails_helper"

RSpec.describe "Notifications", type: :request do
  describe "GET /notifications" do
    it "turns the bell link into a return link to the previous page" do
      user = create(:user, :resident)

      sign_in user
      get notifications_path, headers: { "HTTP_REFERER" => tickets_url }

      expect(response).to have_http_status(:ok)
      expect(response.body).to include(%(href="/tickets"))
      expect(response.body).to include(%(title="Fechar notificações"))
    end
  end
end
