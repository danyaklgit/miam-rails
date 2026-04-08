import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "preview", "urls"]

  connect() {
    this.images = []
    // Load existing images from hidden input
    try {
      const existing = JSON.parse(this.urlsTarget.value || "[]")
      existing.forEach(url => this.addImage(url, false))
    } catch (e) { /* empty */ }
  }

  get csrf() {
    return document.querySelector("meta[name='csrf-token']")?.content
  }

  async pick() {
    this.inputTarget.click()
  }

  async upload(event) {
    const files = Array.from(event.target.files)
    for (const file of files) {
      const form = new FormData()
      form.append("file", file)

      const placeholder = this.addPlaceholder()
      try {
        const resp = await fetch("/api/upload", {
          method: "POST",
          headers: { "X-CSRF-Token": this.csrf },
          body: form
        })
        const data = await resp.json()
        if (data.url) {
          this.replacePlaceholder(placeholder, data.url)
        } else {
          placeholder.remove()
        }
      } catch {
        placeholder.remove()
      }
    }
    // Reset file input so the same file can be selected again
    event.target.value = ""
  }

  addPlaceholder() {
    const div = document.createElement("div")
    div.className = "h-20 w-20 shrink-0 rounded-xl bg-gray-100 animate-pulse"
    this.previewTarget.insertBefore(div, this.previewTarget.lastElementChild)
    return div
  }

  replacePlaceholder(placeholder, url) {
    this.images.push(url)
    this.syncHiddenField()

    const wrapper = document.createElement("div")
    wrapper.className = "relative h-20 w-20 shrink-0 group"
    wrapper.innerHTML = `
      <img src="${url}" class="h-20 w-20 rounded-xl object-cover">
      <button type="button" data-action="click->image-upload#remove" data-url="${url}"
        class="absolute -top-1.5 -right-1.5 hidden group-hover:flex h-5 w-5 items-center justify-center rounded-full bg-red-500 text-white text-xs shadow">
        &times;
      </button>
    `
    placeholder.replaceWith(wrapper)
  }

  addImage(url, sync = true) {
    this.images.push(url)
    if (sync) this.syncHiddenField()

    const wrapper = document.createElement("div")
    wrapper.className = "relative h-20 w-20 shrink-0 group"
    wrapper.innerHTML = `
      <img src="${url}" class="h-20 w-20 rounded-xl object-cover">
      <button type="button" data-action="click->image-upload#remove" data-url="${url}"
        class="absolute -top-1.5 -right-1.5 hidden group-hover:flex h-5 w-5 items-center justify-center rounded-full bg-red-500 text-white text-xs shadow">
        &times;
      </button>
    `
    this.previewTarget.insertBefore(wrapper, this.previewTarget.lastElementChild)
  }

  remove(event) {
    event.preventDefault()
    event.stopPropagation()
    const url = event.currentTarget.dataset.url
    this.images = this.images.filter(u => u !== url)
    this.syncHiddenField()
    event.currentTarget.closest(".group").remove()
  }

  syncHiddenField() {
    this.urlsTarget.value = JSON.stringify(this.images)
  }
}
