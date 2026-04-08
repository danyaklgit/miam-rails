import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input"]
  static values = { restaurantId: String }

  async validate() {
    const code = this.inputTarget.value.trim()
    if (!code) return

    const response = await fetch("/api/promo/validate", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": document.querySelector("meta[name='csrf-token']")?.content
      },
      body: JSON.stringify({
        restaurant_id: this.restaurantIdValue,
        promo_code: code
      })
    })

    const data = await response.json()
    if (data.valid) {
      this.inputTarget.classList.add("border-green-500")
      this.inputTarget.classList.remove("border-red-500")
    } else {
      this.inputTarget.classList.add("border-red-500")
      this.inputTarget.classList.remove("border-green-500")
    }
  }
}
