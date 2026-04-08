import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.audioCtx = null
    this.lastCount = this.element.querySelectorAll("[id^='ticket_']").length

    // Listen for Turbo Stream appends
    this.observer = new MutationObserver((mutations) => {
      const newCount = this.element.querySelectorAll("[id^='ticket_']").length
      if (newCount > this.lastCount) {
        this.playChime()
      }
      this.lastCount = newCount
    })

    this.observer.observe(this.element, { childList: true, subtree: true })
  }

  disconnect() {
    this.observer?.disconnect()
  }

  playChime() {
    if (!this.audioCtx) {
      this.audioCtx = new (window.AudioContext || window.webkitAudioContext)()
    }
    const ctx = this.audioCtx

    // Two-tone chime
    const osc1 = ctx.createOscillator()
    const osc2 = ctx.createOscillator()
    const gain = ctx.createGain()

    osc1.type = "sine"
    osc1.frequency.value = 880
    osc2.type = "sine"
    osc2.frequency.value = 1320

    gain.gain.setValueAtTime(0.3, ctx.currentTime)
    gain.gain.exponentialRampToValueAtTime(0.01, ctx.currentTime + 0.5)

    osc1.connect(gain)
    osc2.connect(gain)
    gain.connect(ctx.destination)

    osc1.start(ctx.currentTime)
    osc2.start(ctx.currentTime + 0.1)
    osc1.stop(ctx.currentTime + 0.5)
    osc2.stop(ctx.currentTime + 0.6)
  }
}
