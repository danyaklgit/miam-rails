import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "step", "stepIndicator", "stepLine", "form", "summary",
    "partySizeBtn", "largePartyBtn", "customSizeWrapper", "customSizeInput",
    "partySizeField", "dateField", "timeField",
    "nameField", "phoneField", "emailField",
    "step1Next", "step2Next"
  ]

  connect() {
    this.currentStep = 1
    this.partySize = null
    this.isLargeParty = false
    this.updateStepDisplay()
  }

  selectPartySize(event) {
    this.partySize = parseInt(event.params.size)
    this.isLargeParty = false
    this.partySizeFieldTarget.value = this.partySize
    this.customSizeWrapperTarget.classList.add("hidden")

    // Update button styles
    this.partySizeBtnTargets.forEach(btn => {
      const size = parseInt(btn.textContent.trim())
      if (size === this.partySize) {
        btn.style.backgroundColor = "var(--miam-primary)"
        btn.classList.add("text-white", "shadow-md", "scale-105")
        btn.classList.remove("bg-gray-100", "text-gray-700")
      } else {
        btn.style.backgroundColor = ""
        btn.classList.remove("text-white", "shadow-md", "scale-105")
        btn.classList.add("bg-gray-100", "text-gray-700")
      }
    })
    this.largePartyBtnTarget.style.backgroundColor = ""
    this.largePartyBtnTarget.classList.remove("text-white", "shadow-md", "scale-105")
    this.largePartyBtnTarget.classList.add("bg-gray-100", "text-gray-700")

    this.validateStep1()
  }

  selectLargeParty() {
    this.isLargeParty = true
    this.partySize = null
    this.customSizeWrapperTarget.classList.remove("hidden")

    this.partySizeBtnTargets.forEach(btn => {
      btn.style.backgroundColor = ""
      btn.classList.remove("text-white", "shadow-md", "scale-105")
      btn.classList.add("bg-gray-100", "text-gray-700")
    })
    this.largePartyBtnTarget.style.backgroundColor = "var(--miam-primary)"
    this.largePartyBtnTarget.classList.add("text-white", "shadow-md", "scale-105")
    this.largePartyBtnTarget.classList.remove("bg-gray-100", "text-gray-700")

    this.validateStep1()
  }

  updateCustomSize() {
    const val = parseInt(this.customSizeInputTarget.value)
    if (val >= 9) {
      this.partySize = val
      this.partySizeFieldTarget.value = val
    }
    this.validateStep1()
  }

  validateStep1() {
    const hasSize = this.partySize && this.partySize > 0
    const hasDate = this.dateFieldTarget.value !== ""
    const hasTime = this.timeFieldTarget.value !== ""
    this.step1NextTarget.disabled = !(hasSize && hasDate && hasTime)
  }

  validateStep2() {
    const hasName = this.nameFieldTarget.value.trim() !== ""
    const hasPhone = this.phoneFieldTarget.value.trim() !== ""
    const hasEmail = this.emailFieldTarget.value.trim() !== ""
    this.step2NextTarget.disabled = !(hasName && hasPhone && hasEmail)
  }

  nextStep() {
    if (this.currentStep < 3) {
      this.currentStep++
      this.updateStepDisplay()
      if (this.currentStep === 3) this.buildSummary()
    }
  }

  prevStep() {
    if (this.currentStep > 1) {
      this.currentStep--
      this.updateStepDisplay()
    }
  }

  updateStepDisplay() {
    this.stepTargets.forEach(el => {
      const step = parseInt(el.dataset.step)
      el.classList.toggle("hidden", step !== this.currentStep)
    })

    this.stepIndicatorTargets.forEach(el => {
      const step = parseInt(el.dataset.step)
      if (step < this.currentStep) {
        el.style.backgroundColor = "var(--miam-primary)"
        el.classList.add("text-white")
        el.classList.remove("bg-gray-200", "text-gray-400")
        el.innerHTML = '<svg class="h-4 w-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"/></svg>'
      } else if (step === this.currentStep) {
        el.style.backgroundColor = "var(--miam-primary)"
        el.classList.add("text-white", "shadow-lg", "scale-110")
        el.classList.remove("bg-gray-200", "text-gray-400")
        el.textContent = step
      } else {
        el.style.backgroundColor = ""
        el.classList.remove("text-white", "shadow-lg", "scale-110")
        el.classList.add("bg-gray-200", "text-gray-400")
        el.textContent = step
      }
    })

    this.stepLineTargets.forEach(el => {
      const step = parseInt(el.dataset.step)
      if (step < this.currentStep) {
        el.style.backgroundColor = "var(--miam-primary)"
        el.classList.remove("bg-gray-200")
      } else {
        el.style.backgroundColor = ""
        el.classList.add("bg-gray-200")
      }
    })
  }

  buildSummary() {
    const date = this.dateFieldTarget.value
    const time = this.timeFieldTarget.value
    const name = this.nameFieldTarget.value
    const size = this.partySizeFieldTarget.value

    const dateFormatted = new Date(date + "T00:00:00").toLocaleDateString("en-US", {
      weekday: "long", year: "numeric", month: "long", day: "numeric"
    })

    this.summaryTarget.innerHTML = `
      <div class="flex items-center gap-3">
        <svg class="h-5 w-5" style="color: var(--miam-primary)" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z"/></svg>
        <div><p class="text-xs text-gray-500">Date</p><p class="font-medium text-gray-900">${dateFormatted}</p></div>
      </div>
      <div class="flex items-center gap-3">
        <svg class="h-5 w-5" style="color: var(--miam-primary)" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z"/></svg>
        <div><p class="text-xs text-gray-500">Time</p><p class="font-medium text-gray-900">${time}</p></div>
      </div>
      <div class="flex items-center gap-3">
        <svg class="h-5 w-5" style="color: var(--miam-primary)" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4.354a4 4 0 110 5.292M15 21H3v-1a6 6 0 0112 0v1zm0 0h6v-1a6 6 0 00-9-5.197M13 7a4 4 0 11-8 0 4 4 0 018 0z"/></svg>
        <div><p class="text-xs text-gray-500">Party Size</p><p class="font-medium text-gray-900">${size} ${size == 1 ? 'guest' : 'guests'}</p></div>
      </div>
      <div class="border-t border-gray-200 pt-3">
        <p class="text-xs text-gray-500">Name</p><p class="font-medium text-gray-900">${name}</p>
      </div>
    `
  }

  // Auto-validate on field input
  dateFieldTargetConnected() { this.dateFieldTarget.addEventListener("change", () => this.validateStep1()) }
  timeFieldTargetConnected() { this.timeFieldTarget.addEventListener("change", () => this.validateStep1()) }
  nameFieldTargetConnected() { this.nameFieldTarget.addEventListener("input", () => this.validateStep2()) }
  phoneFieldTargetConnected() { this.phoneFieldTarget.addEventListener("input", () => this.validateStep2()) }
  emailFieldTargetConnected() { this.emailFieldTarget.addEventListener("input", () => this.validateStep2()) }
}
