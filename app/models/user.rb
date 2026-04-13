class User < ApplicationRecord
  has_many :user_units, dependent: :destroy
  has_many :units, through: :user_units
  has_many :user_ticket_types, dependent: :destroy
  has_many :assigned_ticket_types, through: :user_ticket_types, source: :ticket_type

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  enum :role, { resident: 0, collaborator: 1, administrator: 2 }, default: :resident
  validates :name, presence: true
end
