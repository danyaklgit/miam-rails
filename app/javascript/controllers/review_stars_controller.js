import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["star", "feedbackSection", "feedback", "submitSection", "submitButton"]
  static values = { restaurantId: String, orderId: String, googleUrl: String }

  connect() {
    this.rating = 0
  }

  rate(event) {
    this.rating = parseInt(event.params.value)
    this.updateStars()

    // Show feedback for low ratings, submit button for all
    if (this.rating > 0 && this.rating <= 3) {
      this.feedbackSectionTarget.classList.remove("hidden")
    } else {
      this.feedbackSectionTarget.classList.add("hidden")
    }

    this.submitSectionTarget.classList.remove("hidden")
    this.submitButtonTarget.textContent = this.rating >= 4
      ? "Submit & rate on Google"
      : "Submit feedback"
  }

  updateStars() {
    this.starTargets.forEach((star, index) => {
      if (index < this.rating) {
        star.classList.remove("text-gray-300")
        star.classList.add("text-yellow-400")
      } else {
        star.classList.remove("text-yellow-400")
        star.classList.add("text-gray-300")
      }
    })
  }

  async submit() {
    const feedback = this.hasFeedbackTarget ? this.feedbackTarget.value : ""
    const redirectToGoogle = this.rating >= 4 && this.googleUrlValue

    await fetch("/api/reviews", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": document.querySelector("meta[name='csrf-token']")?.content
      },
      body: JSON.stringify({
        restaurant_id: this.restaurantIdValue,
        order_id: this.orderIdValue,
        rating: this.rating,
        feedback: feedback,
        redirected_to_google: !!redirectToGoogle
      })
    })

    if (redirectToGoogle) {
      window.open(this.googleUrlValue, "_blank")
    }

    // Replace review section with thank you
    this.element.innerHTML = '<p class="font-semibold text-green-600">Thanks for your feedback!</p>'
  }
}
