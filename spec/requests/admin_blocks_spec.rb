require "rails_helper"

RSpec.describe "Admin blocks", type: :request do
  describe "POST /blocks" do
    it "allows admin to create block" do
      admin = create(:user, :administrator)
      sign_in admin

      expect do
        post blocks_path, params: {
          block: {
            identification: "B",
            floors_count: 2,
            apartments_per_floor: 2
          }
        }
      end.to change(Block, :count).by(1)

      expect(response).to redirect_to(blocks_path)
    end

    it "generates units automatically using floor+apartment pattern" do
      admin = create(:user, :administrator)
      sign_in admin

      expect do
        post blocks_path, params: {
          block: {
            identification: "C",
            floors_count: 2,
            apartments_per_floor: 3
          }
        }
      end.to change(Unit, :count).by(6)

      block = Block.order(:id).last
      identifiers = block.units.order(:identifier).pluck(:identifier)

      expect(identifiers).to eq(%w[101 102 103 201 202 203])
    end
  end
end
