class TicketStatus < ApplicationRecord
  has_many :tickets, dependent: :restrict_with_exception

  validates :name, presence: true, uniqueness: { case_sensitive: false }
  validates :is_default, inclusion: { in: [ true, false ] }
  validates :is_final, inclusion: { in: [ true, false ] }

  validate :only_one_default, if: :is_default?
  validate :opened_status_rules

  private

  def only_one_default
    if TicketStatus.where(is_default: true).where.not(id: id).exists?
      errors.add(:is_default, "já existe um status padrão")
    end
  end

  def opened_status_rules
    return if name.blank?

    if opened_status?
      errors.add(:is_default, "deve permanecer marcado para o status Aberto") unless is_default?
      errors.add(:is_final, "não pode ser marcado para o status Aberto") if is_final?
    elsif is_default?
      errors.add(:is_default, "só pode ser marcado no status Aberto")
    end
  end

  def opened_status?
    I18n.transliterate(name.to_s).downcase.strip == "aberto"
  end
end
