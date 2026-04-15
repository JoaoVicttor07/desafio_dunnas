class Ticket < ApplicationRecord
  MAX_ATTACHMENT_SIZE = 5.megabytes
  MAX_ATTACHMENTS = 1
  ALLOWED_ATTACHMENT_CONTENT_TYPES = %w[
    image/png
    image/jpeg
    image/webp
    image/gif
    image/heic
    image/heif
  ].freeze

  belongs_to :unit
  belongs_to :user
  belongs_to :ticket_type
  belongs_to :ticket_status

  has_many :comments, dependent: :destroy
  has_many :notifications, dependent: :destroy
  has_many_attached :attachments

  attr_accessor :acting_user, :reopen_reason, :closing_note

  validates :description, presence: true
  validates :ticket_status, presence: true

  before_validation :set_default_status, on: :create
  before_validation :sync_resolved_at_with_status

  validate :resident_unit_must_be_linked, on: :create
  validate :resolved_at_only_when_final
  validate :validate_reopen_conditions, on: :update
  validate :validate_closing_note_if_concluding, on: :update
  validate :validate_status_transition_rules, on: :update
  validate :validate_attachments

  after_update_commit :log_reopen_action, if: :transitioned_to_reopened?

  def allowed_next_statuses_for(user)
    status = ticket_status || TicketStatus.find_by(is_default: true)
    keys = case normalized_status_name(status)
           when "concluido"
             user&.administrator? ? ["reaberto"] : []
           else
             allowed_next_status_keys_for(status)
           end

    TicketStatus.order(:name).select { |ticket_status| keys.include?(normalized_status_name(ticket_status)) }
  end

  private

  def set_default_status
    self.ticket_status ||= TicketStatus.find_by(is_default: true)
  end

  def resident_unit_must_be_linked
    return if user.blank? || unit_id.blank?
    return unless user.resident?

    unless user.units.exists?(id: unit_id)
      errors.add(:unit_id, "não está vinculada ao morador")
    end
  end

  def sync_resolved_at_with_status
    return unless will_save_change_to_ticket_status_id?

    if ticket_status&.is_final?
      self.resolved_at ||= Time.current
    else
      self.resolved_at = nil
    end
  end

  def resolved_at_only_when_final
    return if resolved_at.blank?
    return if ticket_status&.is_final?
    errors.add(:resolved_at, "só pode existir quando o chamado estiver concluído")
  end

  def validate_reopen_conditions
    return unless transitioning_to_reopened?

    unless acting_user&.administrator?
      errors.add(:base, "Apenas administradores podem reabrir chamados concluídos.")
      return
    end

    if reopen_reason.to_s.strip.blank?
      errors.add(:reopen_reason, "é obrigatório ao reabrir um chamado.")
    end
  end

  def currently_concluding?
    return false unless ticket_status_id_changed?

    old_status_id, new_status_id = ticket_status_id_change
    old_status = TicketStatus.find_by(id: old_status_id)
    new_status = TicketStatus.find_by(id: new_status_id)

    !old_status&.is_final? && new_status&.is_final?
  end

  def validate_closing_note_if_concluding
    return unless currently_concluding?
    return unless closing_note.to_s.strip.blank?

    errors.add(:closing_note, "é obrigatório ao concluir um chamado.")
  end

  def validate_status_transition_rules
    return unless ticket_status_id_changed?

    old_status_id, new_status_id = ticket_status_id_change
    old_status = TicketStatus.find_by(id: old_status_id)
    new_status = TicketStatus.find_by(id: new_status_id)

    old_key = normalized_status_name(old_status)
    new_key = normalized_status_name(new_status)
    allowed_keys = allowed_next_status_keys_for(old_status)

    return if old_key == new_key

    unless allowed_keys.include?(new_key)
      errors.add(:ticket_status, "não permite a transição de #{status_label(old_status)} para #{status_label(new_status)}.")
    end
  end

  def transitioned_to_reopened?
    return false unless saved_change_to_ticket_status_id?

    old_status_id, new_status_id = saved_change_to_ticket_status_id
    old_status = TicketStatus.find_by(id: old_status_id)
    new_status = TicketStatus.find_by(id: new_status_id)

    old_status&.is_final? && normalized_status_name(new_status) == "reaberto"
  end

  def transitioning_to_reopened?
    return false unless ticket_status_id_changed?

    old_status_id, new_status_id = ticket_status_id_change
    old_status = TicketStatus.find_by(id: old_status_id)
    new_status = TicketStatus.find_by(id: new_status_id)

    old_status&.is_final? && normalized_status_name(new_status) == "reaberto"
  end

  def log_reopen_action
    comments.create!(
      user: acting_user || user,
      body: "Chamado reaberto automaticamente.\nMotivo informado: #{reopen_reason}"
    )
  end

  def allowed_next_status_keys_for(status)
    case normalized_status_name(status)
    when "aberto"
      ["em andamento", "concluido"]
    when "em andamento"
      ["concluido"]
    when "concluido"
      acting_user&.administrator? ? ["reaberto"] : []
    when "reaberto"
      ["concluido"]
    else
      []
    end
  end

  def status_label(status)
    return "Sem status" if status.blank?

    status.name
  end

  def normalized_status_name(status)
    I18n.transliterate(status&.name.to_s).downcase.strip
  end

  def validate_attachments
    return unless attachments.attached?

    if attachments.count > MAX_ATTACHMENTS
      errors.add(:attachments, "permitem apenas 1 imagem por chamado")
    end

    attachments.each do |attachment|
      unless ALLOWED_ATTACHMENT_CONTENT_TYPES.include?(attachment.content_type)
        errors.add(:attachments, "devem conter apenas imagens (PNG, JPG, WEBP, GIF ou HEIC)")
      end

      if attachment.byte_size > MAX_ATTACHMENT_SIZE
        errors.add(:attachments, "#{attachment.filename} excede o limite de 5MB")
      end
    end
  end
end