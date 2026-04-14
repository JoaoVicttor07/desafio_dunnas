module ApplicationHelper
	def navigation_items_for(user)
		return [] unless user

		if user.administrator?
			return [
				{
					label: "Chamados",
					icon: "C",
					children: [
						{ label: "Visualizar chamados", path: tickets_path, controllers: %w[tickets comments] },
						{ label: "Tipos de chamados", path: ticket_types_path, controllers: %w[ticket_types] },
						{ label: "Status de chamados", path: ticket_statuses_path, controllers: %w[ticket_statuses] }
					]
				},
				{
					label: "Condominio",
					icon: "B",
					children: [
						{ label: "Blocos e unidades", path: blocks_path, controllers: %w[blocks] },
						{ label: "Vinculos morador-unidade", path: admin_user_units_path, controllers: %w[admin/user_units admin/units] }
					]
				},
				{ label: "Usuarios", path: admin_users_path, icon: "U", controllers: %w[admin/users] }
			]
		end

		if user.collaborator?
			return [
				{
					label: "Chamados",
					icon: "C",
					children: [
						{ label: "Visualizar chamados", path: tickets_path, controllers: %w[tickets comments] }
					]
				}
			]
		end

		[
			{
				label: "Chamados",
				icon: "C",
				children: [
					{ label: "Meus chamados", path: tickets_path, controllers: %w[tickets comments] }
				]
			}
		]
	end

	def navigation_item_active?(item)
		if item[:children].present?
			return item[:children].any? { |child| navigation_item_active?(child) }
		end

		return true if current_page?(item[:path])

		item.fetch(:controllers, []).include?(controller_path)
	end

	def navigation_group_open?(item)
		navigation_item_active?(item)
	end

	def navigation_link_classes(active, mobile: false)
		base = "group flex items-center gap-3 rounded-xl px-4 py-3 text-sm font-semibold transition-all duration-200"

		if active
			"#{base} bg-white text-[#3a266b] shadow-sm"
		elsif mobile
			"#{base} text-violet-100 hover:bg-white/12 hover:text-white"
		else
			"#{base} text-violet-100 hover:bg-white/12 hover:text-white"
		end
	end

	def navigation_group_button_classes(active, mobile: false)
		base = "group flex w-full items-center justify-between rounded-xl px-4 py-3 text-left text-sm font-semibold transition-all duration-200"

		if active
			"#{base} bg-white text-[#3a266b] shadow-sm"
		elsif mobile
			"#{base} text-violet-100 hover:bg-white/12 hover:text-white"
		else
			"#{base} text-violet-100 hover:bg-white/12 hover:text-white"
		end
	end

	def navigation_sub_link_classes(active)
		base = "flex items-center rounded-lg px-3 py-2 text-sm transition-all duration-200"

		if active
			"#{base} bg-white text-[#3a266b] font-semibold"
		else
			"#{base} text-violet-100/90 hover:bg-white/10 hover:text-white"
		end
	end

	def navigation_badge_classes(active)
		if active
			"inline-flex h-7 w-7 items-center justify-center rounded-lg bg-[#e9e2ff] text-xs font-bold text-[#3a266b]"
		else
			"inline-flex h-7 w-7 items-center justify-center rounded-lg bg-white/20 text-xs font-bold text-white"
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
