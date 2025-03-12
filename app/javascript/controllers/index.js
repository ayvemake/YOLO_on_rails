// Import and register all your controllers from the importmap under controllers/**/*_controller
import { application } from "controllers/application"
import { eagerLoadControllersFrom } from "@hotwired/stimulus-loading"
eagerLoadControllersFrom("controllers", application)

// Manually register controllers
import NavbarController from "controllers/navbar_controller"
application.register("navbar", NavbarController)
