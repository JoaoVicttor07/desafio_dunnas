open = TicketStatus.find_or_create_by!(name: "Aberto") do |s|
  s.is_default = true
  s.is_final = false
end

TicketStatus.find_or_create_by!(name: "Em andamento") do |s|
  s.is_default = false
  s.is_final = false
end

TicketStatus.find_or_create_by!(name: "Concluído") do |s|
  s.is_default = false
  s.is_final = true
end

TicketStatus.where.not(id: open.id).update_all(is_default: false)
