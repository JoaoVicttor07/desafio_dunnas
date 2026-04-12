class TicketType < ApplicationRecord
    validates :title, presence: true, uniqueness: { case_sensitive: false }
    validates :sla_hours, presence: true, numericality: { only_integer: true, greater_than: 0 }
end
