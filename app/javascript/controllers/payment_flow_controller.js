import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "sheet", "title", "content",
    "stepSplit", "stepItems", "stepEqual", "stepCustom", "stepTip", "stepDone",
    "itemsList", "itemsTotal",
    "equalAmount", "totalPeopleCount", "sharesCount", "sharesPlural",
    "equalInfo", "equalInfoText", "splitAcrossDecBtn", "splitAcrossIncBtn",
    "customInput",
    "billAmount", "tipBtn", "customTipSection", "customTipInput",
    "tipBillDisplay", "tipAmountDisplay", "tipTotalDisplay", "payButton",
    "doneMessage"
  ]
  static values = { orderId: String, total: Number, paid: Number, left: Number, slug: String, primaryColor: String, splitConfig: Object }

  connect() {
    this.splitType = null
    this.paymentAmount = 0
    this.tipPercent = null
    this.customTip = 0
    this.totalPeople = 2
    this.sharesToPay = 1
    this.selectedItemPayments = []
    this.paymentMade = false

    this.openHandler = () => this.open()
    window.addEventListener("payment:open", this.openHandler)

    // Auto-open after page refresh triggered by cart drawer
    if (sessionStorage.getItem("open_payment_after_refresh")) {
      sessionStorage.removeItem("open_payment_after_refresh")
      requestAnimationFrame(() => this.open())
    }
  }

  disconnect() {
    window.removeEventListener("payment:open", this.openHandler)
  }

  get csrf() {
    return document.querySelector("meta[name='csrf-token']")?.content
  }

  open() {
    this.showStep("split")
    this.element.classList.remove("hidden")
    requestAnimationFrame(() => this.sheetTarget.classList.remove("translate-y-full"))
  }

  close() {
    this.sheetTarget.classList.add("translate-y-full")
    setTimeout(() => {
      this.element.classList.add("hidden")
      if (this.paymentMade) {
        this.paymentMade = false
        const scrollY = window.scrollY
        document.addEventListener("turbo:load", () => window.scrollTo(0, scrollY), { once: true })
        window.Turbo.visit(window.location.href, { action: "replace" })
      }
    }, 300)
  }

  showStep(step) {
    const steps = ["Split", "Items", "Equal", "Custom", "Tip", "Done"]
    steps.forEach(s => {
      const target = this[`step${s}Target`]
      if (target) target.classList.toggle("hidden", s.toLowerCase() !== step)
    })
    const titles = { split: "Pay your bill", items: "Select items", equal: "Split equally", custom: "Custom amount", tip: "Add a tip", done: "Done" }
    this.titleTarget.textContent = titles[step] || "Pay"
  }

  // Step 1: Split selection
  selectSplit(event) {
    this.splitType = event.currentTarget.dataset.split
    if (this.splitType === "full") {
      this.paymentAmount = this.leftValue
      this.goToTip()
    } else if (this.splitType === "items") {
      this.showStep("items")
    } else if (this.splitType === "equal") {
      this.initEqualSplit()
      this.showStep("equal")
    } else if (this.splitType === "custom") {
      this.showStep("custom")
    }
  }

  backToSplit() { this.showStep("split") }

  // Step 2a: Items
  updateItemTotal() {
    let total = 0
    this.selectedItemPayments = []
    const itemCounts = {}

    this.itemsListTarget.querySelectorAll("input[type='checkbox']:checked").forEach(cb => {
      total += parseFloat(cb.dataset.unitPrice)
      const itemId = cb.dataset.itemId
      itemCounts[itemId] = (itemCounts[itemId] || 0) + 1
    })

    this.paymentAmount = Math.round(total * 100) / 100
    this.itemsTotalTarget.textContent = `€${this.paymentAmount.toFixed(2)}`
    this.selectedItemPayments = Object.entries(itemCounts).map(([id, qty]) => ({ id, paidQuantity: qty }))
  }

  confirmItems() {
    if (this.paymentAmount <= 0) return
    this.goToTip()
  }

  // Step 2b: Equal split
  initEqualSplit() {
    const sc = this.splitConfigValue || {}
    this.splitLocked = !!(sc.totalPeople && sc.sharesPaid > 0)

    if (this.splitLocked) {
      // Split already configured by a previous payment — lock the total people
      this.totalPeople = sc.totalPeople
      this.sharesPaidAlready = sc.sharesPaid || 0
      const remaining = this.totalPeople - this.sharesPaidAlready
      this.sharesToPay = Math.min(1, remaining)
      this.maxShares = remaining

      // Show info banner
      this.equalInfoTarget.classList.remove("hidden")
      this.equalInfoTextTarget.textContent = `Split across ${this.totalPeople} — ${this.sharesPaidAlready} share${this.sharesPaidAlready === 1 ? '' : 's'} already paid, ${remaining} remaining`

      // Lock the "split across" controls
      this.splitAcrossDecBtnTarget.disabled = true
      this.splitAcrossDecBtnTarget.classList.add("opacity-30", "cursor-not-allowed")
      this.splitAcrossIncBtnTarget.disabled = true
      this.splitAcrossIncBtnTarget.classList.add("opacity-30", "cursor-not-allowed")
    } else {
      // Fresh split — user chooses
      this.totalPeople = 2
      this.sharesToPay = 1
      this.sharesPaidAlready = 0
      this.maxShares = null

      this.equalInfoTarget.classList.add("hidden")
      this.splitAcrossDecBtnTarget.disabled = false
      this.splitAcrossDecBtnTarget.classList.remove("opacity-30", "cursor-not-allowed")
      this.splitAcrossIncBtnTarget.disabled = false
      this.splitAcrossIncBtnTarget.classList.remove("opacity-30", "cursor-not-allowed")
    }

    this.updateEqualAmount()
  }

  incrementTotalPeople() {
    if (this.splitLocked) return
    this.totalPeople++
    this.updateEqualAmount()
  }

  decrementTotalPeople() {
    if (this.splitLocked) return
    if (this.totalPeople > 2) {
      this.totalPeople--
      if (this.sharesToPay > this.totalPeople) this.sharesToPay = this.totalPeople
      this.updateEqualAmount()
    }
  }

  incrementShares() {
    const max = this.maxShares || this.totalPeople
    if (this.sharesToPay < max) {
      this.sharesToPay++
      this.updateEqualAmount()
    }
  }

  decrementShares() {
    if (this.sharesToPay > 1) {
      this.sharesToPay--
      this.updateEqualAmount()
    }
  }

  updateEqualAmount() {
    const perPerson = Math.ceil((this.totalValue / this.totalPeople) * 100) / 100
    this.paymentAmount = Math.min(perPerson * this.sharesToPay, this.leftValue)
    this.equalAmountTarget.textContent = `€${this.paymentAmount.toFixed(2)}`
    this.totalPeopleCountTarget.textContent = this.totalPeople
    this.sharesCountTarget.textContent = this.sharesToPay
    this.sharesPluralTarget.textContent = this.sharesToPay === 1 ? "" : "s"
  }

  confirmEqual() {
    if (this.paymentAmount <= 0) return
    this.goToTip()
  }

  // Step 2c: Custom
  confirmCustom() {
    const val = parseFloat(this.customInputTarget.value) || 0
    this.paymentAmount = Math.min(val, this.leftValue)
    if (this.paymentAmount <= 0) return
    this.goToTip()
  }

  // Step 3: Tip
  goToTip() {
    this.tipPercent = null
    this.customTip = 0
    this.billAmountTarget.textContent = `€${this.paymentAmount.toFixed(2)}`
    this.tipBillDisplayTarget.textContent = `€${this.paymentAmount.toFixed(2)}`
    this.tipAmountDisplayTarget.textContent = "€0.00"
    this.tipTotalDisplayTarget.textContent = `€${this.paymentAmount.toFixed(2)}`
    this.payButtonTarget.textContent = `Pay €${this.paymentAmount.toFixed(2)}`
    this.customTipSectionTarget.classList.add("hidden")

    // Reset button styles
    this.tipBtnTargets.forEach(btn => {
      btn.classList.remove("border-gray-900", "bg-gray-900", "text-white")
      btn.classList.add("border-gray-200")
    })

    this.showStep("tip")
  }

  selectTip(event) {
    this.tipPercent = parseInt(event.currentTarget.dataset.tipPct)
    this.customTip = 0
    this.customTipSectionTarget.classList.add("hidden")
    this.highlightTipBtn(event.currentTarget)
    this.updateTipDisplay()
  }

  selectCustomTip(event) {
    this.tipPercent = null
    this.customTipSectionTarget.classList.remove("hidden")
    this.customTipInputTarget.focus()
    this.highlightTipBtn(event.currentTarget)
  }

  updateCustomTip() {
    this.customTip = parseFloat(this.customTipInputTarget.value) || 0
    this.updateTipDisplay()
  }

  highlightTipBtn(activeBtn) {
    this.tipBtnTargets.forEach(btn => {
      btn.classList.remove("border-gray-900", "bg-gray-900", "text-white")
      btn.classList.add("border-gray-200")
    })
    activeBtn.classList.remove("border-gray-200")
    activeBtn.classList.add("border-gray-900", "bg-gray-900", "text-white")
  }

  updateTipDisplay() {
    const tipAmount = this.tipPercent !== null
      ? Math.round(this.paymentAmount * (this.tipPercent / 100) * 100) / 100
      : this.customTip
    const total = this.paymentAmount + tipAmount
    this.tipBillDisplayTarget.textContent = `€${this.paymentAmount.toFixed(2)}`
    this.tipAmountDisplayTarget.textContent = `€${tipAmount.toFixed(2)}`
    this.tipTotalDisplayTarget.textContent = `€${total.toFixed(2)}`
    this.payButtonTarget.textContent = `Pay €${total.toFixed(2)}`
  }

  // Step 4: Pay
  async pay() {
    this.payButtonTarget.disabled = true
    this.payButtonTarget.textContent = "Processing..."

    const tipAmount = this.tipPercent !== null
      ? Math.round(this.paymentAmount * (this.tipPercent / 100) * 100) / 100
      : this.customTip

    const body = {
      amount: this.paymentAmount,
      tipAmount: tipAmount,
      splitType: this.splitType,
      deviceId: localStorage.getItem("miam_device_id") || "anonymous"
    }

    if (this.splitType === "items" && this.selectedItemPayments.length > 0) {
      body.itemPayments = this.selectedItemPayments
    }

    if (this.splitType === "equal") {
      body.splitConfig = {
        totalPeople: this.totalPeople,
        sharesPaying: this.sharesToPay
      }
    }

    try {
      const resp = await fetch(`/api/orders/${this.orderIdValue}/pay`, {
        method: "POST",
        headers: { "Content-Type": "application/json", "X-CSRF-Token": this.csrf },
        body: JSON.stringify(body)
      })
      const data = await resp.json()

      if (data.isFullyPaid) {
        window.Turbo.visit(`/${this.slugValue}/receipt/${this.orderIdValue}`, { action: "replace" })
      } else {
        this.paymentMade = true
        const remaining = (this.leftValue - this.paymentAmount).toFixed(2)
        this.doneMessageTarget.textContent = `You paid €${(this.paymentAmount + tipAmount).toFixed(2)}. Remaining: €${remaining}`
        this.showStep("done")
      }
    } catch (err) {
      this.payButtonTarget.disabled = false
      this.payButtonTarget.textContent = `Pay €${(this.paymentAmount + tipAmount).toFixed(2)}`
    }
  }
}
