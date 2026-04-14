module ApplicationHelper
	def navigation_items_for(user)
		return [] unless user

		if user.administrator?
			return [
				{ label: "Chamados", path: tickets_path, controllers: %w[tickets comments] },
				{ label: "Blocos e Unidades", path: blocks_path, controllers: %w[blocks] },
				{ label: "Usuarios", path: admin_users_path, controllers: %w[admin/users] },
				{ label: "Vinculos", path: admin_user_units_path, controllers: %w[admin/user_units admin/units] },
				{ label: "Tipos de Chamado", path: ticket_types_path, controllers: %w[ticket_types] },
				{ label: "Status de Chamado", path: ticket_statuses_path, controllers: %w[ticket_statuses] }
			]
		end

		if user.collaborator?
			return [
				{ label: "Chamados", path: tickets_path, controllers: %w[tickets comments] }
			]
		end

		[
			{ label: "Meus Chamados", path: tickets_path, controllers: %w[tickets comments] }
		]
	end

	def navigation_item_active?(item)
		return true if current_page?(item[:path])

		item.fetch(:controllers, []).include?(controller_path)
	end

	def navigation_link_classes(active, mobile: false)
		base = "group flex items-center gap-3 rounded-xl px-4 py-3 text-sm font-semibold transition-all duration-200"

		if active
			"#{base} bg-white text-blue-900 shadow-sm"
		elsif mobile
			"#{base} text-blue-100 hover:bg-white/10 hover:text-white"
		else
			"#{base} text-blue-100 hover:bg-white/10 hover:text-white"
		end
	end

	def page_heading
		if content_for?(:page_heading)
			content_for(:page_heading)
		elsif content_for?(:title)
			content_for(:title).split("|").first.strip
		else
			"Painel"
		end
	end

	def role_label(user)
		return "Administrador" if user.administrator?
		return "Colaborador" if user.collaborator?

		"Morador"
	end
end
