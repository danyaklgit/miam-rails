import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { interval: { type: Number, default: 5000 }, url: String }

  connect() {
    this.paused = false
    this.timer = setInterval(() => this.refresh(), this.intervalValue)

    // Pause when a detail panel or drawer is open
    this.pauseHandler = () => { this.paused = true }
    this.resumeHandler = () => { this.paused = false }
    window.addEventListener("auto-refresh:pause", this.pauseHandler)
    window.addEventListener("auto-refresh:resume", this.resumeHandler)
  }

  disconnect() {
    clearInterval(this.timer)
    window.removeEventListener("auto-refresh:pause", this.pauseHandler)
    window.removeEventListener("auto-refresh:resume", this.resumeHandler)
  }

  refresh() {
    if (document.hidden) return
    if (this.paused) return

    const url = this.urlValue || window.location.href
    window.Turbo.visit(url, { action: "replace" })
  }
}
