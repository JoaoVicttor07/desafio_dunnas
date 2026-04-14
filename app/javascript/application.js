// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"

document.addEventListener("turbo:load", () => {
	const drawer = document.querySelector("#mobile-nav")
	const overlay = document.querySelector("#mobile-nav-overlay")
	const openButton = document.querySelector("[data-nav-open]")
	const closeButton = document.querySelector("[data-nav-close]")

	if (!drawer || !overlay || !openButton || !closeButton) return

	const setOpen = (isOpen) => {
		if (isOpen) {
			drawer.classList.remove("-translate-x-full")
			overlay.classList.remove("hidden")
			document.body.classList.add("overflow-hidden")
			return
		}

		drawer.classList.add("-translate-x-full")
		overlay.classList.add("hidden")
		document.body.classList.remove("overflow-hidden")
	}

	openButton.onclick = () => setOpen(true)
	closeButton.onclick = () => setOpen(false)
	overlay.onclick = () => setOpen(false)
})
