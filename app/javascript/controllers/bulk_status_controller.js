import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { ids: Array, status: String, tableNum: String }

  async update() {
    this.element.disabled = true
    this.element.textContent = "Updating..."

    const csrf = document.querySelector("meta[name='csrf-token']")?.content

    await fetch("/api/order_items/bulk_update_status", {
      method: "PATCH",
      headers: { "Content-Type": "application/json", "X-CSRF-Token": csrf },
      body: JSON.stringify({ ids: this.idsValue, status: this.statusValue })
    })

    const tableNum = this.tableNumValue
    window.Turbo.visit(window.location.href, { action: "replace" })
    document.addEventListener("turbo:load", function handler() {
      document.removeEventListener("turbo:load", handler)
      const btn = document.querySelector(`[data-floor-table-number-param="${tableNum}"]`)
      if (btn) btn.click()
    })
  }
}
