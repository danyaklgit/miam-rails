import { Controller } from "@hotwired/stimulus"

// Watches the order_status_signal for changes (via Turbo Stream broadcasts)
// and refreshes the tracking page to show the latest status.
export default class extends Controller {
  connect() {
    this.observer = new MutationObserver(() => {
      window.Turbo.visit(window.location.href, { action: "replace" })
    })
    this.observer.observe(this.element, { childList: true, subtree: true, attributes: true })
  }

  disconnect() {
    this.observer?.disconnect()
  }
}
