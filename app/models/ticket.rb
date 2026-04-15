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

  attr_accessor :acting_user, :reopen_reason

  validates :description, presence: true
  validates :ticket_status, presence: true

  before_validation :set_default_status, on: :create
  before_validation :sync_resolved_at_with_status

  validate :resident_unit_must_be_linked, on: :create
  validate :resolved_at_only_when_final
  validate :validate_reopen_conditions, on: :update
  validate :validate_attachments

  after_update_commit :log_reopen_action, if: :reopened?

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

  def currently_reopening?
    return false unless ticket_status_id_changed?

    old_status_id, new_status_id = ticket_status_id_change
    old_status = TicketStatus.find_by(id: old_status_id)
    new_status = TicketStatus.find_by(id: new_status_id)

    old_status&.is_final? && !new_status&.is_final?
  end

  def validate_reopen_conditions
    return unless currently_reopening?

    unless acting_user&.administrator?
      errors.add(:base, "Apenas administradores podem reabrir chamados concluídos.")
      return
    end

    if reopen_reason.blank?
      errors.add(:reopen_reason, "(Motivo) é obrigatório ao reabrir um chamado.")
    end
  end

  def reopened?
    return false unless saved_change_to_ticket_status_id?
    
    old_status_id, new_status_id = saved_change_to_ticket_status_id
    old_status = TicketStatus.find_by(id: old_status_id)
    new_status = TicketStatus.find_by(id: new_status_id)

    old_status&.is_final? && !new_status&.is_final?
  end

  def log_reopen_action
    comments.create!(
      user: acting_user || user,
      body: "⚠️ Ação Automática: Chamado REABERTO.\nMotivo: #{reopen_reason}"
    )
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