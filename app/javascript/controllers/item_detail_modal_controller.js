import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "sheet", "imageGallery", "noImageHeader", "mainImage",
    "name", "price", "description", "allergens",
    "variantsSection", "variantsList", "notes", "quantity", "addButton"
  ]

  connect() {
    this.qty = 1
    this.selectedVariant = null
    this.item = null

    // Listen for open events from item-modal controllers
    this.handleOpen = (e) => this.open(e.detail.item, e.detail.primaryColor)
    window.addEventListener("item-modal:open", this.handleOpen)
  }

  disconnect() {
    window.removeEventListener("item-modal:open", this.handleOpen)
  }

  open(item, primaryColor) {
    this.item = item
    this.qty = 1
    this.selectedVariant = null
    this.quantityTarget.textContent = "1"
    this.notesTarget.value = ""

    // Name + price
    this.nameTarget.textContent = item.name
    const price = Number(item.price).toFixed(2)
    this.priceTarget.textContent = `€${price}`
    this.priceTarget.style.color = primaryColor

    // Description
    if (item.description) {
      this.descriptionTarget.textContent = item.description
      this.descriptionTarget.classList.remove("hidden")
    } else {
      this.descriptionTarget.classList.add("hidden")
    }

    // Images
    const images = item.images || []
    if (images.length > 0) {
      this.mainImageTarget.src = images[0]
      this.imageGalleryTarget.classList.remove("hidden")
      this.noImageHeaderTarget.classList.add("hidden")
    } else {
      this.imageGalleryTarget.classList.add("hidden")
      this.noImageHeaderTarget.classList.remove("hidden")
    }

    // Allergens
    const allergens = item.allergens || []
    if (allergens.length > 0) {
      this.allergensTarget.innerHTML = allergens.map(a =>
        `<span class="rounded-full bg-red-50 px-2.5 py-1 text-xs font-medium text-red-700">${a}</span>`
      ).join("")
      this.allergensTarget.classList.remove("hidden")
    } else {
      this.allergensTarget.classList.add("hidden")
    }

    // Variants
    const variants = item.variants || []
    if (variants.length > 0) {
      this.variantsListTarget.innerHTML = variants.map(v => {
        const modifier = Number(v.priceModifier || 0)
        const label = modifier > 0 ? `${v.name} (+€${modifier.toFixed(2)})` : v.name
        return `<button data-variant-id="${v.id}" data-variant-name="${v.name}" data-variant-modifier="${modifier}"
          data-action="click->item-detail-modal#selectVariant"
          class="rounded-xl border-2 border-gray-200 px-4 py-2 text-sm font-medium transition-colors hover:border-gray-400">${label}</button>`
      }).join("")
      this.variantsSectionTarget.classList.remove("hidden")
    } else {
      this.variantsSectionTarget.classList.add("hidden")
    }

    // Add button styling
    this.addButtonTarget.style.backgroundColor = primaryColor
    this.updateAddButtonText()

    // Show modal
    this.element.classList.remove("hidden")
    requestAnimationFrame(() => {
      this.sheetTarget.classList.remove("translate-y-full")
    })
  }

  close() {
    this.sheetTarget.classList.add("translate-y-full")
    setTimeout(() => this.element.classList.add("hidden"), 300)
  }

  increment() {
    this.qty = Math.min(this.qty + 1, 99)
    this.quantityTarget.textContent = this.qty
    this.updateAddButtonText()
  }

  decrement() {
    this.qty = Math.max(this.qty - 1, 1)
    this.quantityTarget.textContent = this.qty
    this.updateAddButtonText()
  }

  selectVariant(event) {
    const btn = event.currentTarget
    // Deselect all
    this.variantsListTarget.querySelectorAll("button").forEach(b => {
      b.classList.remove("border-gray-900", "bg-gray-900", "text-white")
      b.classList.add("border-gray-200")
    })
    // Select this one
    btn.classList.remove("border-gray-200")
    btn.classList.add("border-gray-900", "bg-gray-900", "text-white")
    this.selectedVariant = {
      id: btn.dataset.variantId,
      name: btn.dataset.variantName,
      priceModifier: Number(btn.dataset.variantModifier)
    }
    this.updateAddButtonText()
  }

  updateAddButtonText() {
    const basePrice = Number(this.item.price)
    const modifier = this.selectedVariant?.priceModifier || 0
    const total = ((basePrice + modifier) * this.qty).toFixed(2)
    this.addButtonTarget.textContent = `Add to order · €${total}`
  }

  addToOrder() {
    const data = {
      menu_item_id: this.item.id,
      name: this.item.name,
      price: this.item.price,
      quantity: this.qty,
      notes: this.notesTarget.value,
      type: this.item.type || "food",
      variant_id: this.selectedVariant?.id,
      variant_name: this.selectedVariant?.name,
      variant_price_modifier: this.selectedVariant?.priceModifier || 0
    }

    window.dispatchEvent(new CustomEvent("cart:add-item", { detail: data }))
    this.close()
  }
}
