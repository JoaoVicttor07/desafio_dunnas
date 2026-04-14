class TicketTypesController < ApplicationController
  before_action :authenticate_user!
  load_and_authorize_resource
  before_action :set_ticket_type, only: %i[ show edit update destroy ]

  # GET /ticket_types or /ticket_types.json
  def index
    @ticket_types = TicketType.all
  end

  # GET /ticket_types/new
  def new
    @ticket_type = TicketType.new
  end

  # GET /ticket_types/1/edit
  def edit
  end

  # POST /ticket_types or /ticket_types.json
  def create
    @ticket_type = TicketType.new(ticket_type_params)

    if @ticket_type.save
      redirect_to ticket_types_path, notice: "Tipo de chamado criado com sucesso."
    else
      render :new, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /ticket_types/1 or /ticket_types/1.json
  def update
    if @ticket_type.update(ticket_type_params)
      redirect_to ticket_types_path, notice: "Tipo de chamado atualizado com sucesso.", status: :see_other
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /ticket_types/1 or /ticket_types/1.json
  def destroy
    @ticket_type.destroy!
    redirect_to ticket_types_path, notice: "Tipo de chamado removido com sucesso.", status: :see_other
  end

  private

    def set_ticket_type
      @ticket_type = TicketType.find(params[:id])
    end

    def ticket_type_params
      params.require(:ticket_type).permit(:title, :sla_hours, collaborator_ids: [])
    end
end
