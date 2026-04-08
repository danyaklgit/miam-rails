import { Controller } from "@hotwired/stimulus"

// Watches a table-level broadcast signal and refreshes the page
// when the order state changes and this client doesn't yet have
// an order-level Turbo Stream subscription.
export default class extends Controller {
  connect() {
    this.observer = new MutationObserver(() => this.onSignalChange())
    this.observer.observe(this.element, { childList: true, subtree: true, attributes: true })
  }

  disconnect() {
    this.observer?.disconnect()
  }

  onSignalChange() {
    const cartEl = document.querySelector("[data-cart-order-id-value]")
    const hasOrder = cartEl && cartEl.dataset.cartOrderIdValue

    if (!hasOrder) {
      // No order on this page yet — refresh to pick up the new order + subscription
      const scrollY = window.scrollY
      document.addEventListener("turbo:load", () => {
        window.scrollTo(0, scrollY)
      }, { once: true })
      window.Turbo.visit(window.location.href, { action: "replace" })
    }
  }
}
