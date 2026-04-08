import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { itemId: String, nextStatus: String, orderId: String }

  get csrf() {
    return document.querySelector("meta[name='csrf-token']")?.content
  }

  async advance() {
    // Disable the button that was clicked
    const btn = this.element.tagName === "BUTTON"
      ? this.element
      : this.element.querySelector("[data-action*='ticket#advance']")

    if (btn) {
      btn.disabled = true
      btn.textContent = "..."
    }

    const resp = await fetch(`/api/order_items/${this.itemIdValue}/update_status`, {
      method: "PATCH",
      headers: { "Content-Type": "application/json", "X-CSRF-Token": this.csrf },
      body: JSON.stringify({ status: this.nextStatusValue })
    })

    if (!resp.ok) {
      if (btn) { btn.disabled = false; btn.textContent = "Retry" }
      return
    }

    // Check if we're inside a floor detail panel — if so, reload the panel
    const floorPanel = this.element.closest("[data-floor-table-target='panel']")
    if (floorPanel) {
      // On floor view — reload the page but preserve scroll and re-open the same panel
      const tableNum = floorPanel.dataset.tableNumber
      // Brief delay to let the broadcast propagate, then reload
      setTimeout(() => {
        const scrollY = window.scrollY
        window.Turbo.visit(window.location.href, { action: "replace" })
        // Re-open panel after Turbo replaces the page
        document.addEventListener("turbo:load", function handler() {
          document.removeEventListener("turbo:load", handler)
          window.scrollTo(0, scrollY)
          // Click the same table to re-open
          const tableBtn = document.querySelector(`[data-floor-table-number-param="${tableNum}"]`)
          if (tableBtn) tableBtn.click()
        })
      }, 200)
      return
    }

    // Kitchen/bar display — update ticket in-place
    const ticket = this.element.closest("[id^='ticket_']") || this.element

    if (this.nextStatusValue === "served") {
      ticket.classList.add("opacity-0", "scale-95", "transition-all", "duration-500")
      setTimeout(() => ticket.remove(), 500)
    } else {
      const statusMap = {
        preparing: { border: "border-yellow-500", badge: "bg-yellow-500", btn: "bg-green-600 hover:bg-green-500", next: "ready", label: "→ Ready" },
        ready: { border: "border-green-500", badge: "bg-green-500", btn: "bg-gray-600 hover:bg-gray-500", next: "served", label: "→ Served" },
        served: { border: "border-gray-600", badge: "bg-gray-600", btn: null, next: null, label: null }
      }
      const s = statusMap[this.nextStatusValue]
      if (s) {
        ticket.classList.remove("border-red-500", "border-yellow-500", "border-green-500")
        ticket.classList.add(s.border)

        const badge = ticket.querySelector("[class*='rounded-full'][class*='font-bold'][class*='text-white']")
        if (badge) {
          badge.className = badge.className.replace(/bg-(red|yellow|green)-\d+/g, "")
          badge.classList.add(s.badge)
          badge.textContent = this.nextStatusValue.charAt(0).toUpperCase() + this.nextStatusValue.slice(1)
        }

        if (btn && s.next) {
          btn.className = `rounded-lg px-3 py-1.5 text-xs font-bold text-white transition-colors ${s.btn}`
          btn.textContent = s.label
          btn.disabled = false
          this.nextStatusValue = s.next
        } else if (btn) {
          btn.remove()
        }
      }
    }
  }

  async advanceOrder() {
    const btn = this.element.tagName === "BUTTON" ? this.element : this.element.querySelector("[data-action*='ticket#advanceOrder']")
    if (btn) {
      btn.disabled = true
      btn.textContent = "..."
    }

    await fetch(`/api/orders/${this.orderIdValue}/status`, {
      method: "PATCH",
      headers: { "Content-Type": "application/json", "X-CSRF-Token": this.csrf },
      body: JSON.stringify({ status: this.nextStatusValue })
    })

    window.Turbo.visit(window.location.href, { action: "replace" })
  }
}
