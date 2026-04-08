import { Application } from "@hotwired/stimulus"

const application = Application.start()
application.debug = false
window.Stimulus = application

// Customer controllers
import HeroParallaxController from "./hero_parallax_controller"
import ItemModalController from "./item_modal_controller"
import CartController from "./cart_controller"
import PromoCodeController from "./promo_code_controller"
import ReviewStarsController from "./review_stars_controller"
import ReservationWizardController from "./reservation_wizard_controller"

import ItemDetailModalController from "./item_detail_modal_controller"
import AccordionController from "./accordion_controller"

application.register("hero-parallax", HeroParallaxController)
application.register("item-modal", ItemModalController)
application.register("item-detail-modal", ItemDetailModalController)
application.register("accordion", AccordionController)
import CartDrawerController from "./cart_drawer_controller"
import PickupTimeController from "./pickup_time_controller"
import PaymentFlowController from "./payment_flow_controller"
import LiveFabController from "./live_fab_controller"
import TableSyncController from "./table_sync_controller"
import OrderTrackingController from "./order_tracking_controller"

application.register("cart", CartController)
application.register("cart-drawer", CartDrawerController)
application.register("pickup-time", PickupTimeController)
application.register("payment-flow", PaymentFlowController)
application.register("live-fab", LiveFabController)
application.register("table-sync", TableSyncController)
application.register("order-tracking", OrderTrackingController)
application.register("promo-code", PromoCodeController)
application.register("review-stars", ReviewStarsController)
application.register("reservation-wizard", ReservationWizardController)

// Display controllers
import TicketController from "./ticket_controller"
import ElapsedTimerController from "./elapsed_timer_controller"
import AudioChimeController from "./audio_chime_controller"
import ViewToggleController from "./view_toggle_controller"
import AutoRefreshController from "./auto_refresh_controller"

application.register("ticket", TicketController)
application.register("elapsed-timer", ElapsedTimerController)
application.register("audio-chime", AudioChimeController)
application.register("view-toggle", ViewToggleController)
application.register("auto-refresh", AutoRefreshController)

// Dashboard controllers
import SidebarController from "./sidebar_controller"
import RestaurantSwitcherController from "./restaurant_switcher_controller"
import ModalController from "./modal_controller"

import FloorTableController from "./floor_table_controller"
import BulkStatusController from "./bulk_status_controller"
import ImageUploadController from "./image_upload_controller"
import SingleImageUploadController from "./single_image_upload_controller"

application.register("sidebar", SidebarController)
application.register("restaurant-switcher", RestaurantSwitcherController)
application.register("modal", ModalController)
application.register("floor-table", FloorTableController)
application.register("bulk-status", BulkStatusController)
application.register("image-upload", ImageUploadController)
application.register("single-image-upload", SingleImageUploadController)

export { application }
