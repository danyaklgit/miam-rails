import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["sheet", "body"]
  static values = { refreshUrl: String }

  connect() {
    this.openHandler = () => this.open()
    window.addEventListener("cart-drawer:open", this.openHandler)

    // Watch order_items_list for changes — refresh drawer if it's open
    this.itemsObserver = new MutationObserver(() => this.onItemsChanged())
    const list = document.getElementById("order_items_list")
    if (list) {
      this.itemsObserver.observe(list, { childList: true, subtree: true, attributes: true })
    }
  }

  disconnect() {
    window.removeEventListener("cart-drawer:open", this.openHandler)
    this.itemsObserver?.disconnect()
  }

  get isOpen() {
    return !this.element.classList.contains("hidden")
  }

  async onItemsChanged() {
    if (!this.isOpen || !this.refreshUrlValue) return
    try {
      const resp = await fetch(this.refreshUrlValue)
      if (resp.ok && this.hasBodyTarget) {
        this.bodyTarget.innerHTML = await resp.text()
      }
    } catch (e) { /* silent */ }
  }

  get csrf() {
    return document.querySelector("meta[name='csrf-token']")?.content
  }

  async open() {
    // Always fetch fresh drawer content from server
    if (this.refreshUrlValue) {
      try {
        const resp = await fetch(this.refreshUrlValue)
        if (resp.ok && this.hasBodyTarget) {
          this.bodyTarget.innerHTML = await resp.text()
        }
      } catch (e) { /* proceed with existing content */ }
    }

    this.element.classList.remove("hidden")
    requestAnimationFrame(() => {
      this.sheetTarget.classList.remove("translate-y-full")
    })
  }

  close() {
    this.sheetTarget.classList.add("translate-y-full")
    setTimeout(() => this.element.classList.add("hidden"), 300)
  }

  // Takeaway quantity controls
  async increment(event) {
    const idx = event.currentTarget.dataset.index
    await fetch(`/api/cart/update/${idx}`, {
      method: "PATCH",
      headers: { "Content-Type": "application/json", "X-CSRF-Token": this.csrf },
      body: JSON.stringify({ quantity: this.getQty(event) + 1 })
    })
    window.Turbo.visit(window.location.href, { action: "replace" })
  }

  async decrement(event) {
    const idx = event.currentTarget.dataset.index
    const newQty = this.getQty(event) - 1
    if (newQty <= 0) {
      await this.remove(event)
    } else {
      await fetch(`/api/cart/update/${idx}`, {
        method: "PATCH",
        headers: { "Content-Type": "application/json", "X-CSRF-Token": this.csrf },
        body: JSON.stringify({ quantity: newQty })
      })
      window.Turbo.visit(window.location.href, { action: "replace" })
    }
  }

  async remove(event) {
    const idx = event.currentTarget.dataset.index
    await fetch(`/api/cart/remove/${idx}`, {
      method: "DELETE",
      headers: { "X-CSRF-Token": this.csrf }
    })
    window.Turbo.visit(window.location.href, { action: "replace" })
  }

  getQty(event) {
    const row = event.currentTarget.closest("[class*='rounded-xl']")
    const qtyEl = row?.querySelector("[class*='text-center']")
    return parseInt(qtyEl?.textContent || "1")
  }

  // Dine-in: change pending item quantity
  async incrementDineIn(event) {
    const itemId = event.currentTarget.dataset.itemId
    const qty = parseInt(event.currentTarget.dataset.qty) || 1
    await this.updateDineInQuantity(itemId, qty + 1)
  }

  async decrementDineIn(event) {
    const itemId = event.currentTarget.dataset.itemId
    const qty = parseInt(event.currentTarget.dataset.qty) || 1
    if (qty <= 1) {
      await this.removeDineInItem(itemId)
    } else {
      await this.updateDineInQuantity(itemId, qty - 1)
    }
  }

  async updateDineInQuantity(itemId, newQty) {
    await fetch(`/api/order_items/${itemId}/update_quantity`, {
      method: "PATCH",
      headers: { "Content-Type": "application/json", "X-CSRF-Token": this.csrf },
      body: JSON.stringify({ quantity: newQty })
    })
    // Re-fetch drawer content to reflect new quantity/total
    if (this.refreshUrlValue && this.hasBodyTarget) {
      try {
        const resp = await fetch(this.refreshUrlValue)
        if (resp.ok) this.bodyTarget.innerHTML = await resp.text()
      } catch (e) { /* silent */ }
    }
  }

  async removeDineInItem(itemId) {
    await fetch(`/api/order_items/${itemId}`, {
      method: "DELETE",
      headers: { "X-CSRF-Token": this.csrf }
    })
    if (this.refreshUrlValue && this.hasBodyTarget) {
      try {
        const resp = await fetch(this.refreshUrlValue)
        if (resp.ok) this.bodyTarget.innerHTML = await resp.text()
      } catch (e) { /* silent */ }
    }
  }

  // Dine-in: remove pending item (trash icon)
  async removeItem(event) {
    const itemId = event.currentTarget.dataset.itemId
    await this.removeDineInItem(itemId)
  }

  // Dine-in: confirm pending items (send to kitchen)
  async confirmOrder(event) {
    const btn = event.currentTarget
    btn.disabled = true
    btn.textContent = "Sending..."

    const orderId = btn.dataset.orderId
    await fetch(`/api/orders/${orderId}/confirm`, {
      method: "POST",
      headers: { "Content-Type": "application/json", "X-CSRF-Token": this.csrf }
    })
    this.close()
    window.Turbo.visit(window.location.href, { action: "replace" })
  }

  // Dine-in: open payment flow
  openPayment() {
    window.dispatchEvent(new CustomEvent("payment:open"))
  }
}
