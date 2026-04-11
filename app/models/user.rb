class User < ApplicationRecord
  has_many :user_units, dependent: :destroy
  has_many :units, through: :user_units
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  enum :role, { resident: 0, collaborator: 1, administrator: 2 }, default: :resident
  validates :name, presence: true
end
