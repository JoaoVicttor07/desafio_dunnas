class TicketStatus < ApplicationRecord
  has_many :tickets, dependent: :restrict_with_exception

  validates :name, presence: true, uniqueness: { case_sensitive: false }
  validates :is_default, inclusion: { in: [ true, false ] }
  validates :is_final, inclusion: { in: [ true, false ] }

  validate :only_one_default, if: :is_default?

  private

  def only_one_default
    if TicketStatus.where(is_default: true).where.not(id: id).exists?
      errors.add(:is_default, "já existe um status padrão")
    end
  end
end
