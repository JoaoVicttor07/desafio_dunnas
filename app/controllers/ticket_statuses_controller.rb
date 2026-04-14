class TicketStatusesController < ApplicationController
  before_action :authenticate_user!
  load_and_authorize_resource
  before_action :set_ticket_status, only: %i[ show edit update destroy ]

  # GET /ticket_statuses or /ticket_statuses.json
  def index
    @ticket_statuses = TicketStatus.all
  end

  # GET /ticket_statuses/new
  def new
    @ticket_status = TicketStatus.new
  end

  # GET /ticket_statuses/1/edit
  def edit
  end

  # POST /ticket_statuses or /ticket_statuses.json
  def create
    @ticket_status = TicketStatus.new(ticket_status_params)

    if @ticket_status.save
      redirect_to ticket_statuses_path, notice: "Status criado com sucesso."
    else
      render :new, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /ticket_statuses/1 or /ticket_statuses/1.json
  def update
    if @ticket_status.update(ticket_status_params)
      redirect_to ticket_statuses_path, notice: "Status atualizado com sucesso.", status: :see_other
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /ticket_statuses/1 or /ticket_statuses/1.json
  def destroy
    @ticket_status.destroy!
    redirect_to ticket_statuses_path, notice: "Status removido com sucesso.", status: :see_other
  end

  private

    def set_ticket_status
      @ticket_status = TicketStatus.find(params[:id])
    end

    def ticket_status_params
      params.require(:ticket_status).permit(:name, :is_default, :is_final)
    end
end
