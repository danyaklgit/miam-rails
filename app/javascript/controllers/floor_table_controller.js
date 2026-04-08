import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["panel"]

  connect() {
    // Restore previously open panel after auto-refresh
    const savedTable = sessionStorage.getItem("floor_open_table")
    if (savedTable) {
      requestAnimationFrame(() => this.openPanel(savedTable, false))
    }
  }

  select(event) {
    const tableNum = String(event.params.number)
    sessionStorage.setItem("floor_open_table", tableNum)
    this.openPanel(tableNum, true)
  }

  openPanel(tableNum, scroll) {
    const container = document.getElementById("floor-table-detail")
    if (!container) return

    container.classList.remove("hidden")

    this.panelTargets.forEach(panel => {
      panel.classList.toggle("hidden", panel.dataset.tableNumber !== tableNum)
    })

    if (scroll) container.scrollIntoView({ behavior: "smooth", block: "start" })
  }

  close() {
    document.getElementById("floor-table-detail")?.classList.add("hidden")
    sessionStorage.removeItem("floor_open_table")
  }
}
