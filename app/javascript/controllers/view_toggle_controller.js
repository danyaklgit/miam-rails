import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  switch(event) {
    const mode = event.params.mode
    const url = new URL(window.location)
    url.searchParams.set("view", mode)
    window.Turbo.visit(url.toString(), { action: "replace" })
  }
}
