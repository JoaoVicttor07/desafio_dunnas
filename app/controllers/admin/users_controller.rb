module Admin
  class UsersController < BaseController
    load_and_authorize_resource class: "User"

    def index
      @users = @users.order(created_at: :desc)
    end

    def new
    end

    def create
      if @user.save
        redirect_to admin_users_path, notice: "Usuário criado com sucesso."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
    end

    def update
      if @user.update(user_params)
        redirect_to admin_users_path, notice: "Usuário atualizado com sucesso."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      if @user == current_user
        redirect_to admin_users_path, alert: "Você não pode excluir seu próprio usuário."
        return
      end

      @user.destroy!
      redirect_to admin_users_path, notice: "Usuário removido com sucesso."
    end

    private

    def user_params
      permitted = [:name, :email, :role, :password, :password_confirmation]
      permitted << :role unless @user == current_user
      p = params.require(:user).permit(*permitted)

      if p[:password].blank?
        p.delete(:password)
        p.delete(:password_confirmation)
      end

      p
    end
  end
end