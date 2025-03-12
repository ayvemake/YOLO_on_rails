// Entry point for the build script
import "@hotwired/turbo-rails"
import "@hotwired/stimulus"
import "./controllers"

// Initialize Stimulus application
const application = Application.start()

// Register controllers
application.register("navbar", NavbarController)
