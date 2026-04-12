class Ticket < ApplicationRecord
  belongs_to :unit
  belongs_to :user
  belongs_to :ticket_type
  belongs_to :ticket_status

  has_many :comments, dependent: :destroy
  has_many_attached :attachments

  validates :description, presence: true
  validates :ticket_status, presence: true

  before_validation :set_default_status, on: :create
  validate :resident_unit_must_be_linked, on: :create
  validate :resolved_at_only_when_final

  before_save :sync_resolved_at_with_status

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
end
