import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["option", "input"]

  select(event) {
    const value = event.params.value
    this.inputTarget.value = value

    const primaryColor = getComputedStyle(document.documentElement).getPropertyValue("--miam-primary").trim() || "#000000"

    this.optionTargets.forEach(btn => {
      const isActive = btn.dataset.pickupTimeValueParam === value
      if (isActive) {
        btn.style.borderColor = primaryColor
        btn.style.backgroundColor = primaryColor
        btn.style.color = "#ffffff"
        btn.classList.add("font-semibold")
        btn.classList.remove("font-medium")
      } else {
        btn.style.borderColor = primaryColor + "20"
        btn.style.backgroundColor = "transparent"
        btn.style.color = ""
        btn.classList.remove("font-semibold")
        btn.classList.add("font-medium")
      }
    })
  }
}
