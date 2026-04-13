class TicketsController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_resident_has_units!, only: %i[new create]
  load_and_authorize_resource

  # GET /tickets or /tickets.json
  def index
    @filters = params.permit(:ticket_status_id, :ticket_type_id, :unit_id)

    @tickets = @tickets
    .includes(:ticket_status, :ticket_type, unit: :block)
    .order(created_at: :desc)

    if @filters[:ticket_status_id].present?
      @tickets = @tickets.where(ticket_status_id: @filters[:ticket_status_id])
    end

    if @filters[:ticket_type_id].present?
      @tickets = @tickets.where(ticket_type_id: @filters[:ticket_type_id])
    end

    if @filters[:unit_id].present?
      @tickets = @tickets.where(unit_id: @filters[:unit_id])
    end
  end

  # GET /tickets/1 or /tickets/1.json
  def show
  end

  # GET /tickets/new
  def new
    @ticket.user = current_user
  end

  # GET /tickets/1/edit
  def edit
  end

  # POST /tickets or /tickets.json
  def create
    @ticket.user = current_user
    if current_user.resident? && current_user.units.none?
      redirect_to tickets_path, alert: "Você não possui unidade vinculada. Contate o administrador."
      return
    end
    
    respond_to do |format|
      if @ticket.save
        format.html { redirect_to @ticket, notice: "Chamado aberto com sucesso!" }
        format.json { render :show, status: :created, location: @ticket }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @ticket.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /tickets/1 or /tickets/1.json
  def update
    respond_to do |format|
      if @ticket.update(ticket_params)
        format.html { redirect_to @ticket, notice: "Chamado atualizado com sucesso.", status: :see_other }
        format.json { render :show, status: :ok, location: @ticket }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @ticket.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /tickets/1 or /tickets/1.json
  def destroy
    @ticket.destroy!

    respond_to do |format|
      format.html { redirect_to tickets_path, notice: "Chamado excluido com sucesso.", status: :see_other }
      format.json { head :no_content }
    end
  end

  private

  def ensure_resident_has_units!
    return unless current_user.resident?
    return if current_user.units.exists?

    redirect_to tickets_path, alert: "Você não possui unidade vinculada. Contate o administrador."
  end

  def ticket_params
    permitted =
      if action_name == "create"
        [:unit_id, :ticket_type_id, :description]
      else
        [:description]
      end

    if (current_user.administrator? || current_user.collaborator?) && action_name != "create"
      permitted << :ticket_status_id
    end

    params.require(:ticket).permit(*permitted, attachments: [])
  end
end
