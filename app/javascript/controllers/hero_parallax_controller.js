import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["image", "overlay", "content", "scrollBtn", "img"]

  connect() {
    this.onScroll = this.scroll.bind(this)
    window.addEventListener("scroll", this.onScroll, { passive: true })

    // Fade in image on load
    if (this.hasImgTarget) {
      if (this.imgTarget.complete) {
        this.fadeInImage()
      } else {
        this.imgTarget.addEventListener("load", () => this.fadeInImage())
      }
    }
  }

  disconnect() {
    window.removeEventListener("scroll", this.onScroll)
  }

  fadeInImage() {
    if (this.hasImageTarget) this.imageTarget.style.opacity = "0.8"
    if (this.hasOverlayTarget) this.overlayTarget.style.opacity = "1"
  }

  scroll() {
    const scrollY = window.scrollY
    const viewH = window.innerHeight

    // Parallax image at 50% scroll speed
    if (this.hasImageTarget) {
      this.imageTarget.style.transform = `translate3d(0, ${scrollY * 0.5}px, 0)`
    }

    // Content fades and lifts
    if (this.hasContentTarget) {
      const opacity = Math.max(0, 1 - scrollY / (viewH * 0.5))
      this.contentTarget.style.opacity = opacity
      this.contentTarget.style.transform = `translate3d(0, ${scrollY * 0.3}px, 0)`
    }

    // Scroll button fades
    if (this.hasScrollBtnTarget) {
      const opacity = Math.max(0, 1 - scrollY / (viewH * 0.3))
      this.scrollBtnTarget.style.opacity = opacity
    }
  }
}
