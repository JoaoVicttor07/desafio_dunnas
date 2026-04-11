class Block < ApplicationRecord
  has_many :units, dependent: :destroy

  validates :identification, :floors_count, :apartments_per_floor, presence: true
  validates :floors_count, :apartments_per_floor, numericality: { greater_than: 0 }

  after_create :generate_units

  private


  # Lógica para gerar sequencia de apartamentos de acordo com a quantidade de andares #
  def generate_units
    (1..floors_count).each do |floor|
      (1..apartments_per_floor).each do |apt|
        apt_number = apt.to_s.rjust(2, "0")
        identifier_name = "#{self.identification} - Andar #{floor} - Apto #{apt_number}"
        units.create!(identifier: identifier_name)
      end
    end
  end
end
