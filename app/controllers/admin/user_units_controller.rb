module Admin
  class UserUnitsController < BaseController
    load_and_authorize_resource class: "UserUnit"

    def index
      @user_unit = UserUnit.new
      @user_units = UserUnit.includes(:user, unit: :block).order(created_at: :desc)
      @residents = User.resident.order(:name)
      @units = Unit.includes(:block).order(:block_id, :identifier)
    end

    def create
      @user_unit = UserUnit.new(user_unit_params)

      if @user_unit.save
        redirect_to admin_user_units_path, notice: "Vínculo criado com sucesso."
      else
        redirect_to admin_user_units_path, alert: @user_unit.errors.full_messages.to_sentence
      end
    end

    def destroy
      @user_unit.destroy!
      redirect_to admin_user_units_path, notice: "Vínculo removido com sucesso."
    end

    private

    def user_unit_params
      params.require(:user_unit).permit(:user_id, :unit_id)
    end
  end
end