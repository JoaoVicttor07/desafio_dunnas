json.extract! ticket, :id, :unit_id, :user_id, :ticket_type_id, :ticket_status_id, :description, :resolved_at, :created_at, :updated_at
json.url ticket_url(ticket, format: :json)
