import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["display"]
  static values = { created: String }

  connect() {
    this.update()
    this.interval = setInterval(() => this.update(), 1000)
  }

  disconnect() {
    clearInterval(this.interval)
  }

  update() {
    const created = new Date(this.createdValue)
    const now = new Date()
    const diff = Math.floor((now - created) / 1000)

    if (diff < 60) {
      this.displayTarget.textContent = `${diff}s`
    } else if (diff < 3600) {
      const m = Math.floor(diff / 60)
      const s = diff % 60
      this.displayTarget.textContent = `${m}:${String(s).padStart(2, "0")}`
    } else {
      const h = Math.floor(diff / 3600)
      const m = Math.floor((diff % 3600) / 60)
      this.displayTarget.textContent = `${h}h${m}m`
    }

    // Color change: red if over 10 minutes
    if (diff > 600) {
      this.displayTarget.classList.add("text-red-400", "font-mono", "font-bold")
      this.displayTarget.classList.remove("text-gray-500")
      // Pulse the parent ticket
      const ticket = this.element.closest("[id^='ticket_']")
      if (ticket) ticket.classList.add("animate-pulse")
    } else if (diff > 300) {
      // Yellow/amber after 5 minutes
      this.displayTarget.classList.add("text-amber-400", "font-mono")
      this.displayTarget.classList.remove("text-gray-500")
    }
  }
}
