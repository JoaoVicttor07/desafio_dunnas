class Ticket < ApplicationRecord
  belongs_to :unit
  belongs_to :user
  belongs_to :ticket_type
  belongs_to :ticket_status

  has_many :comments, dependent: :destroy

  validates :description, presence: true

  validate :resolved_at_cannot_be_in_the_past, on: :update

  private

  def resolved_at_cannot_be_in_the_past
    if resolved_at.present? && resolved_at < created_at
      errors.add(:resolved_at, "não pode ser anterior à data de abertura do chamado")
    end
  end
end
