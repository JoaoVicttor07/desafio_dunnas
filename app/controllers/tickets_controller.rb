class TicketsController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_resident_has_units!, only: %i[new create]
  load_and_authorize_resource

  # GET /tickets or /tickets.json
  def index
    @filters = params.permit(
      :ticket_status_id, 
      :ticket_type_id, 
      :unit_id,
      :block_id,
      :created_from,
      :created_to,
      :q,
      :period
    )

    @tickets = @tickets
    .includes(:ticket_status, :ticket_type, unit: :block)
    .order(created_at: :desc)

    if @filters[:ticket_status_id].present?
      @tickets = @tickets.where(ticket_status_id: @filters[:ticket_status_id])
    end

    if @filters[:ticket_type_id].present?
      @tickets = @tickets.where(ticket_type_id: @filters[:ticket_type_id])
    end

    if current_user.resident? && @filters[:unit_id].present?
      @tickets = @tickets.where(unit_id: @filters[:unit_id])
    end

    if !current_user.resident? && @filters[:block_id].present?
      @tickets = @tickets.joins(unit: :block).where(blocks: { id: @filters[:block_id] })
    end

    if current_user.resident? && @filters[:period].present?
      days = @filters[:period].to_i
      if [7, 30, 90].include?(days)
        @tickets = @tickets.where("tickets.created_at >= ?", days.days.ago.beginning_of_day)
      end
    end

    if @filters[:created_from].present?
      from = Date.parse(@filters[:created_from]) rescue nil
      @tickets = @tickets.where("tickets.created_at >= ?", from.beginning_of_day) if from
  end

    if @filters[:created_to].present?
      to = Date.parse(@filters[:created_to]) rescue nil
      @tickets = @tickets.where("tickets.created_at <= ?", to.end_of_day) if to
    end

    if @filters[:q].present?
      query_text = @filters[:q].strip

      if current_user.resident?
        protocol_text = query_text.sub(/^#/, "")
        q = "%#{query_text}%"

        if protocol_text.match?(/\A\d+\z/)
          @tickets = @tickets.joins(:ticket_type).where(
            "tickets.id = :ticket_id OR ticket_types.title ILIKE :q",
            ticket_id: protocol_text.to_i,
            q: q
          )
        else
          @tickets = @tickets.joins(:ticket_type).where("ticket_types.title ILIKE :q", q: q)
        end
      else
        q = "%#{query_text}%"
        @tickets = @tickets.joins(:ticket_type, unit: :block).where(
          "tickets.description ILIKE :q OR ticket_types.title ILIKE :q OR units.identifier ILIKE :q OR blocks.identification ILIKE :q",
          q: q
        )
      end
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
    @ticket.acting_user = current_user
    closing_note = params.dig(:ticket, :closing_note).to_s.strip

    respond_to do |format|
      if @ticket.update(ticket_params)
        status_change = @ticket.saved_change_to_ticket_status_id
        if status_change.present?
          old_status_id, new_status_id = status_change
          old_status_name = TicketStatus.find_by(id: old_status_id)&.name || "Sem status"
          new_status_name = TicketStatus.find_by(id: new_status_id)&.name || "Sem status"

          ::TicketNotificationService
            .new(ticket: @ticket, actor: current_user)
            .notify_status_changed(old_status_name: old_status_name, new_status_name: new_status_name)

          if concluding_transition?(old_status_id, new_status_id)
            @ticket.comments.create!(
              user: current_user,
              body: "Status alterado de \"#{old_status_name}\" para \"#{new_status_name}\".\nParecer de conclusão: #{closing_note}"
            )
          elsif !reopening_transition?(old_status_id, new_status_id)
            @ticket.comments.create!(
              user: current_user,
              body: "Status alterado de \"#{old_status_name}\" para \"#{new_status_name}\"."
            )
          end
        end

        format.html { redirect_to @ticket, notice: "Chamado atualizado com sucesso.", status: :see_other }
        format.json { render :show, status: :ok, location: @ticket }
      else
        format.html { redirect_to @ticket, alert: @ticket.errors.full_messages.to_sentence }
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

  def reopening_transition?(old_status_id, new_status_id)
    old_status = TicketStatus.find_by(id: old_status_id)
    new_status = TicketStatus.find_by(id: new_status_id)

    old_status&.is_final? && !new_status&.is_final?
  end

  def concluding_transition?(old_status_id, new_status_id)
    old_status = TicketStatus.find_by(id: old_status_id)
    new_status = TicketStatus.find_by(id: new_status_id)

    !old_status&.is_final? && new_status&.is_final?
  end

  def ensure_resident_has_units!
    return unless current_user.resident?
    return if current_user.units.exists?

    redirect_to tickets_path, alert: "Você não possui unidade vinculada. Contate o administrador."
  end

  def ticket_params
    permitted =
      if action_name == "create"
        [:unit_id, :ticket_type_id, :description]
      elsif current_user.administrator?
        [:description, :ticket_status_id, :reopen_reason, :closing_note]
      elsif current_user.collaborator?
        [:ticket_status_id, :closing_note]
      else
        []
      end

    params.require(:ticket).permit(*permitted, attachments: [])
  end
end
