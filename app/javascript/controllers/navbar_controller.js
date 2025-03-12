import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["menu"]

  connect() {
    console.log("Navbar controller connected")
  }

  toggleMenu() {
    console.log("Toggle menu called")
    this.menuTarget.classList.toggle("hidden")
  }
} 