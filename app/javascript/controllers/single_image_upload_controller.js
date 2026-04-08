import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "preview", "url", "placeholder"]

  connect() {
    if (this.urlTarget.value) this.showPreview(this.urlTarget.value)
  }

  get csrf() {
    return document.querySelector("meta[name='csrf-token']")?.content
  }

  pick() {
    this.inputTarget.click()
  }

  async upload(event) {
    const file = event.target.files[0]
    if (!file) return

    this.showLoading()

    const form = new FormData()
    form.append("file", file)

    try {
      const resp = await fetch("/api/upload", {
        method: "POST",
        headers: { "X-CSRF-Token": this.csrf },
        body: form
      })
      const data = await resp.json()
      if (data.url) {
        this.urlTarget.value = data.url
        this.showPreview(data.url)
      } else {
        this.showPlaceholder()
      }
    } catch {
      this.showPlaceholder()
    }

    event.target.value = ""
  }

  remove(event) {
    event.preventDefault()
    event.stopPropagation()
    this.urlTarget.value = ""
    this.showPlaceholder()
  }

  showPreview(url) {
    this.previewTarget.innerHTML = `
      <div class="relative group">
        <img src="${url}" class="h-32 w-full rounded-xl object-cover">
        <button type="button" data-action="click->single-image-upload#remove"
          class="absolute top-2 right-2 hidden group-hover:flex h-6 w-6 items-center justify-center rounded-full bg-red-500 text-white text-xs shadow">
          &times;
        </button>
      </div>
    `
    if (this.hasPlaceholderTarget) this.placeholderTarget.classList.add("hidden")
  }

  showLoading() {
    this.previewTarget.innerHTML = `<div class="h-32 w-full rounded-xl bg-gray-100 animate-pulse"></div>`
    if (this.hasPlaceholderTarget) this.placeholderTarget.classList.add("hidden")
  }

  showPlaceholder() {
    this.previewTarget.innerHTML = ""
    if (this.hasPlaceholderTarget) this.placeholderTarget.classList.remove("hidden")
  }
}
