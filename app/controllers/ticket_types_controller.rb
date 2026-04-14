class TicketTypesController < ApplicationController
  before_action :authenticate_user!
  load_and_authorize_resource
  before_action :set_ticket_type, only: %i[ show edit update destroy ]

  # GET /ticket_types or /ticket_types.json
  def index
    @ticket_types = TicketType.all
  end

  # GET /ticket_types/1 or /ticket_types/1.json
  def show
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

    respond_to do |format|
      if @ticket_type.save
        format.html { redirect_to @ticket_type, notice: "Tipo de chamado criado com sucesso." }
        format.json { render :show, status: :created, location: @ticket_type }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @ticket_type.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /ticket_types/1 or /ticket_types/1.json
  def update
    respond_to do |format|
      if @ticket_type.update(ticket_type_params)
        format.html { redirect_to @ticket_type, notice: "Tipo de chamado atualizado com sucesso.", status: :see_other }
        format.json { render :show, status: :ok, location: @ticket_type }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @ticket_type.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /ticket_types/1 or /ticket_types/1.json
  def destroy
    @ticket_type.destroy!

    respond_to do |format|
      format.html { redirect_to ticket_types_path, notice: "Tipo de chamado removido com sucesso.", status: :see_other }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_ticket_type
      @ticket_type = TicketType.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def ticket_type_params
      params.require(:ticket_type).permit(:title, :sla_hours, collaborator_ids: [])
    end
end
