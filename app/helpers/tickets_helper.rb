module TicketsHelper
	def ticket_sla_badge_classes(ticket)
		case ticket.sla_status_key
		when :breached
			"bg-rose-100 text-rose-800"
		when :at_risk
			"bg-amber-100 text-amber-800"
		when :on_time
			"bg-emerald-100 text-emerald-800"
		else
			"bg-slate-100 text-slate-700"
		end
	end

	def ticket_sla_status_label(ticket)
		case ticket.sla_status_key
		when :breached
			"SLA vencido"
		when :at_risk
			"SLA em risco"
		when :on_time
			"SLA no prazo"
		else
			"Sem SLA"
		end
	end

	def ticket_sla_timing_label(ticket)
		return "Sem prazo configurado" if ticket.sla_due_at.blank?

		delta_seconds = ticket.sla_delta_seconds
		return "Sem prazo configurado" if delta_seconds.nil?

		if delta_seconds.negative?
			prefix = ticket.ticket_status&.is_final? ? "Concluído com atraso de" : "Atrasado em"
			"#{prefix} #{humanize_sla_seconds(delta_seconds.abs)}"
		else
			prefix = ticket.ticket_status&.is_final? ? "Concluído com folga de" : "Restam"
			"#{prefix} #{humanize_sla_seconds(delta_seconds)}"
		end
	end

	private

	def humanize_sla_seconds(total_seconds)
		hours = total_seconds / 3600
		minutes = (total_seconds % 3600) / 60

		if hours.positive?
			"#{hours}h #{minutes}min"
		else
			"#{minutes}min"
		end
	end
end
