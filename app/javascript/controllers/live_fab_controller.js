import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["button", "count", "label", "amount"]
  static values = { primaryColor: String, slug: String, orderId: String }

  connect() {
    this.recalcHandler = () => this.recalculate()
    window.addEventListener("fab:recalculate", this.recalcHandler)

    this.setupObserver()

    if (!this.observing) {
      this.retryTimer = setInterval(() => {
        if (this.setupObserver()) clearInterval(this.retryTimer)
      }, 500)
    }

    // Also watch the order_status_signal for order-level changes
    this.signalObserver = new MutationObserver(() => this.onSignalChange())
    const signal = document.getElementById("order_status_signal")
    if (signal) {
      this.signalObserver.observe(signal, { attributes: true })
      // Also observe parent for replacement of signal element
      this.signalObserver.observe(signal.parentElement, { childList: true })
    }

    this.lastStatusHash = this.getStatusHash()
  }

  disconnect() {
    this.observer?.disconnect()
    this.signalObserver?.disconnect()
    clearInterval(this.retryTimer)
    window.removeEventListener("fab:recalculate", this.recalcHandler)
  }

  setupObserver() {
    const list = document.getElementById("order_items_list")
    if (!list) return false

    if (this.observer) this.observer.disconnect()
    this.observer = new MutationObserver(() => {
      this.recalculate()
      this.checkForStaleItems()
    })
    this.observer.observe(list, { childList: true, subtree: true, attributes: true, attributeFilter: ["data-order-status"] })
    this.observing = true
    return true
  }

  getStatusHash() {
    const list = document.getElementById("order_items_list")
    if (!list) return ""
    return Array.from(list.querySelectorAll("[data-order-status]"))
      .map(el => `${el.id}:${el.dataset.orderStatus}`)
      .join(",")
  }

  onSignalChange() {
    const signal = document.getElementById("order_status_signal")
    if (signal) {
      const total = parseFloat(signal.dataset.total) || 0
      const paid = parseFloat(signal.dataset.paid) || 0
      if (total > 0 && paid >= total) {
        // Order fully paid — redirect all table members to receipt
        window.Turbo.visit(`/${this.slugValue}/receipt/${this.orderIdValue}`, { action: "replace" })
        return
      }
    }
    this.refreshItems()
  }

  // When the order status signal changes, fetch fresh items
  async refreshItems() {
    if (!this.orderIdValue) return
    try {
      const resp = await fetch(`/api/orders/${this.orderIdValue}`)
      if (!resp.ok) return
      const data = await resp.json()
      this.updateItemsList(data.items || [])
    } catch (e) { /* silent */ }
  }

  // Check if Turbo Stream replacements actually updated visible content
  // If the hash changed but items look stale, fetch fresh data
  checkForStaleItems() {
    const newHash = this.getStatusHash()
    if (newHash !== this.lastStatusHash) {
      this.lastStatusHash = newHash
      // Status changed — items should be visually updated by Turbo Stream
      // But as a safety net, schedule a check
      setTimeout(() => this.verifyVisualSync(), 500)
    }
  }

  verifyVisualSync() {
    const list = document.getElementById("order_items_list")
    if (!list) return

    let needsRefresh = false
    list.querySelectorAll("[data-order-status]").forEach(el => {
      const status = el.dataset.orderStatus
      const badge = el.querySelector("[class*='rounded-full'][class*='text-']")
      if (badge && badge.textContent.trim().toLowerCase() !== status) {
        needsRefresh = true
      }
    })

    if (needsRefresh) this.refreshItems()
  }

  updateItemsList(items) {
    const list = document.getElementById("order_items_list")
    if (!list) return

    const statusColors = {
      pending:   { bg: "bg-gray-100", text: "text-gray-600" },
      ordered:   { bg: "bg-red-100", text: "text-red-700" },
      preparing: { bg: "bg-amber-100", text: "text-amber-700" },
      ready:     { bg: "bg-green-100", text: "text-green-700" },
      served:    { bg: "bg-gray-100", text: "text-gray-500" }
    }

    items.forEach(item => {
      const el = document.getElementById(`order_item_${item.id}`)
      if (!el) return

      const sc = statusColors[item.status] || statusColors.ordered
      el.dataset.orderStatus = item.status

      // Update the status badge
      const badge = el.querySelector("[class*='rounded-full'][class*='font-medium']")
      if (badge) {
        badge.className = `rounded-full px-2 py-0.5 text-[10px] font-medium ${sc.bg} ${sc.text}`
        badge.textContent = item.status.charAt(0).toUpperCase() + item.status.slice(1)
      }
    })

    this.recalculate()
  }

  recalculate() {
    const list = document.getElementById("order_items_list")
    if (!list) return

    const items = list.querySelectorAll("[data-order-status]")
    if (items.length === 0) {
      this.element.classList.add("hidden")
      return
    }

    const counts = { pending: 0, ordered: 0, preparing: 0, ready: 0, served: 0 }
    let orderTotal = 0
    items.forEach(el => {
      const status = el.dataset.orderStatus
      if (counts[status] !== undefined) counts[status]++
      orderTotal += parseFloat(el.dataset.itemTotal) || 0
    })

    const total = items.length
    const nonPending = total - counts.pending
    const primary = this.primaryColorValue || "#000000"

    let label, bg
    const allServed = nonPending > 0 && counts.served === nonPending && counts.pending === 0

    if (counts.pending > 0 && nonPending === 0) {
      label = `Review & send ${counts.pending} item${counts.pending === 1 ? '' : 's'} to kitchen`
      bg = "#1f2937"
    } else if (counts.pending > 0) {
      label = `${counts.pending} pending · Send to kitchen`
      bg = "#1f2937"
    } else if (counts.ready > 0 && counts.ready === nonPending - counts.served) {
      label = `${counts.ready} item${counts.ready === 1 ? '' : 's'} ready to be served`
      bg = "#059669"
    } else if (counts.ready > 0) {
      const parts = [`${counts.ready} ready`]
      if (counts.preparing > 0) parts.push(`${counts.preparing} preparing`)
      if (counts.ordered > 0) parts.push(`${counts.ordered} ordered`)
      label = parts.join(" · ")
      bg = "#059669"
    } else if (counts.preparing > 0) {
      label = `${counts.preparing} item${counts.preparing === 1 ? '' : 's'} being prepared`
      bg = "#d97706"
    } else if (counts.ordered > 0) {
      label = `${counts.ordered} item${counts.ordered === 1 ? '' : 's'} sent to kitchen`
      bg = "#dc2626"
    } else if (allServed) {
      label = "All items served · Pay or split bill"
      bg = primary
    } else {
      label = "View order"
      bg = primary
    }

    this.element.classList.remove("hidden")
    if (this.hasButtonTarget) this.buttonTarget.style.backgroundColor = bg
    if (this.hasLabelTarget) this.labelTarget.textContent = label
    if (this.hasCountTarget) this.countTarget.textContent = total
    if (this.hasAmountTarget) {
      const signal = document.getElementById("order_status_signal")
      const paid = signal ? parseFloat(signal.dataset.paid) || 0 : 0
      if (paid > 0 && paid < orderTotal) {
        const remaining = (orderTotal - paid).toFixed(2)
        this.amountTarget.innerHTML = `<s class="opacity-50 mr-1">€${orderTotal.toFixed(2)}</s> €${remaining}`
      } else {
        this.amountTarget.innerHTML = `€${orderTotal.toFixed(2)}`
      }
    }
  }
}
