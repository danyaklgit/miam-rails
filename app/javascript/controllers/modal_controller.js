import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  open(event) {
    const id = event.params.id
    const modal = document.getElementById(id)
    if (modal) {
      modal.classList.remove("hidden")
      requestAnimationFrame(() => {
        modal.querySelector("[data-modal-panel]")?.classList.remove("scale-95", "opacity-0")
        modal.querySelector("[data-modal-panel]")?.classList.add("scale-100", "opacity-100")
      })
    }
  }

  close(event) {
    const modal = event.currentTarget.closest("[data-modal-root]")
    if (modal) {
      modal.querySelector("[data-modal-panel]")?.classList.add("scale-95", "opacity-0")
      modal.querySelector("[data-modal-panel]")?.classList.remove("scale-100", "opacity-100")
      setTimeout(() => modal.classList.add("hidden"), 150)
    }
  }
}
