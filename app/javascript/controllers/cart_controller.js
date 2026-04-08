import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    orderId: String,
    sessionId: String,
    restaurantId: String,
    tableNumber: String,
    mode: { type: String, default: "dineIn" }
  }

  connect() {
    this.handleAddItem = (e) => this.addItem(e.detail)
    window.addEventListener("cart:add-item", this.handleAddItem)
  }

  disconnect() {
    window.removeEventListener("cart:add-item", this.handleAddItem)
  }

  get csrf() {
    return document.querySelector("meta[name='csrf-token']")?.content
  }

  async addItem(itemData) {
    if (this.modeValue === "dineIn") {
      await this.addDineInItem(itemData)
    } else {
      await this.addTakeawayItem(itemData)
    }
  }

  async addDineInItem(itemData) {
    let orderId = this.orderIdValue
    let needsRefresh = false

    // If no session yet, join/create one
    if (!this.sessionIdValue) {
      const joinResp = await fetch("/api/sessions/join", {
        method: "POST",
        headers: { "Content-Type": "application/json", "X-CSRF-Token": this.csrf },
        body: JSON.stringify({
          restaurant_id: this.restaurantIdValue,
          table_number: this.tableNumberValue
        })
      })
      const joinData = await joinResp.json()
      this.sessionIdValue = joinData.session_id
      orderId = joinData.order_id
      needsRefresh = true
    }

    // If no order yet, create one
    if (!orderId) {
      const orderResp = await fetch("/api/orders", {
        method: "POST",
        headers: { "Content-Type": "application/json", "X-CSRF-Token": this.csrf },
        body: JSON.stringify({
          restaurant_id: this.restaurantIdValue,
          type: "dineIn",
          session_id: this.sessionIdValue,
          status: "pending"
        })
      })
      const orderData = await orderResp.json()
      orderId = orderData.id
      this.orderIdValue = orderId
      needsRefresh = true
    }

    // Add item to order (server-side)
    const resp = await fetch(`/api/orders/${orderId}/items`, {
      method: "POST",
      headers: { "Content-Type": "application/json", "X-CSRF-Token": this.csrf },
      body: JSON.stringify({ items: [itemData] })
    })

    if (!resp.ok) return

    this.showAddedToast(itemData.name)

    if (needsRefresh) {
      // First item — refresh to establish Turbo Stream subscription,
      // but preserve scroll position
      this.refreshPreservingScroll()
    }
    // Subsequent items: server broadcasts via Turbo Streams — no refresh needed
  }

  refreshPreservingScroll() {
    const scrollY = window.scrollY
    document.addEventListener("turbo:load", () => {
      window.scrollTo(0, scrollY)
    }, { once: true })
    window.Turbo.visit(window.location.href, { action: "replace" })
  }

  showAddedToast(name) {
    const toast = document.createElement("div")
    toast.className = "fixed top-4 left-1/2 -translate-x-1/2 z-50 rounded-xl bg-gray-900 px-4 py-2.5 text-sm font-medium text-white shadow-lg transition-all"
    toast.textContent = `${name} added to order`
    document.body.appendChild(toast)
    setTimeout(() => {
      toast.classList.add("opacity-0")
      setTimeout(() => toast.remove(), 300)
    }, 1500)
  }

  async addTakeawayItem(itemData) {
    await fetch("/api/cart/add", {
      method: "POST",
      headers: { "Content-Type": "application/json", "X-CSRF-Token": this.csrf },
      body: JSON.stringify(itemData)
    })
    this.refreshPreservingScroll()
  }
}
