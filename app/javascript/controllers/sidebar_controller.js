import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["sidebar", "main", "label", "logo"]

  connect() {
    this.expanded = localStorage.getItem("sidebar_expanded") === "true"
    this.apply()
  }

  toggle() {
    this.expanded = !this.expanded
    localStorage.setItem("sidebar_expanded", this.expanded)
    this.apply()
  }

  apply() {
    if (this.expanded) {
      this.sidebarTarget.classList.remove("w-16")
      this.sidebarTarget.classList.add("w-56")
      this.mainTarget.classList.remove("ml-16")
      this.mainTarget.classList.add("ml-56")
      this.labelTargets.forEach(el => el.classList.remove("hidden"))
      this.logoTarget.classList.remove("hidden")
    } else {
      this.sidebarTarget.classList.remove("w-56")
      this.sidebarTarget.classList.add("w-16")
      this.mainTarget.classList.remove("ml-56")
      this.mainTarget.classList.add("ml-16")
      this.labelTargets.forEach(el => el.classList.add("hidden"))
      this.logoTarget.classList.add("hidden")
    }
  }
}
