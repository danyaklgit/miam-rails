import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { item: Object }

  open() {
    const primaryColor = getComputedStyle(document.documentElement).getPropertyValue("--miam-primary").trim() || "#000000"

    // Dispatch a custom DOM event that the modal controller listens for
    window.dispatchEvent(new CustomEvent("item-modal:open", {
      detail: { item: this.itemValue, primaryColor }
    }))
  }
}
