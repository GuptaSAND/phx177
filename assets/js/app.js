// If you want to use Phoenix channels, run `mix help phx.gen.channel`
// to get started and then uncomment the line below.
// import "./user_socket.js"

// You can include dependencies in two ways.
//
// The simplest option is to put them in assets/vendor and
// import them using relative paths:
//
//     import "../vendor/some-package.js"
//
// Alternatively, you can `npm install some-package --prefix assets` and import
// them using a path starting with the package name:
//
//     import "some-package"
//

// Include phoenix_html to handle method=PUT/DELETE in forms and buttons.
import 'phoenix_html'
// Establish Phoenix Socket and LiveView configuration.
import { Socket } from "phoenix"
import { LiveSocket } from "phoenix_live_view"
import topbar from "../vendor/topbar"
import Alpine from 'alpinejs'
import live_select from "live_select";


//  Hooks
//

const Hooks = {
    AlpineJSHook: {
        mounted() {
            console.log("AlpineJS Hooks : mounted()");
            this.el.addEventListener("daterangepicker", event => {
                console.log("AlpineJS Hooks : daterangepicker()")
                this.pushEvent('daterangepicker', event.detail)
            });
        }
    },
    // live_select component
    live_select: live_select
}

let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")

window.Alpine = Alpine;
Alpine.start();


// Setup the liveSocket
let liveSocket = new LiveSocket("/live", Socket, {
    // timeout parameter in ms defaults to 10 seconds
    timeout: 60000,
    hooks: Hooks,
    params: { _csrf_token: csrfToken },
    dom: {
        onBeforeElUpdated(from, to) {
            if (from._x_dataStack) { window.Alpine.clone(from, to) }
        }
    },
});


// Show progress bar on live navigation and form submits
topbar.config({ barColors: { 0: "#29d" }, shadowColor: "rgba(0, 0, 0, .3)" })
window.addEventListener("phx:page-loading-start", _info => topbar.show(300))
window.addEventListener("phx:page-loading-stop", _info => topbar.hide())


// Alpinejs 
window.addEventListener("alpine:initialized", _info => console.log("AlpineJS initialized !"))

// connect if there are any LiveViews on the page
liveSocket.connect()

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket

