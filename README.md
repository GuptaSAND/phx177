# phx177
 repo for testing phoenix behaviors
 
 ## Purpose
 - provide developer examples on integration techniques with 3rd party components/libraries
 - a UI sample for debugging / experimenting of behaviors, side-effects, issues. 
 - behavioral testing of the framework to ensure all pieces parts still work as expected after framework upgrades

## Pre-requisites:
- Postgres 15.xx
- Elixir 1.15.2 Erlang/OTP 25 [erts-13.2.2.2] (or later)
- Phoenix 1.7.7 (or later)
- LiveView 0.19.5 (or later)


## Installation: 
From assets directory: 
- npm install (will install daisyUI etc under node_modules in assets directory)

From root project directory: 
- mix deps.get (will install hex libs in the deps directory)
- mix compile
- mix ecto.setup (creates the ecto repo - configure dev.exs with your postgres uid/passwd)
- mix assets.deploy (will compile assets and digest/deploy to priv/)

## Running:
- Server: mix phx.server
- Browser: http://localhost:4000


## Notes / Issues: 
### Asset packaging
- Am using phoenix native esbuild. DaisyUI works when included in tailwind.config.js as a plug-in.
There is conflicting documentation in phoenix - recommendation to use npm with build.js script. This is far more complicated. 

- NB> es2017 is esbuild target. esnext (latest) breaks daisyUI behavior of accordions (collapse)

- Have customized the mix.exs (assets.build) & config.exs setups to support dev & prod targets for esbuild (minified in prod)

- Am using phoenix_copy (hex) for copying and watching of static assets (images/fonts/...) to priv/static. Allows for cleaner segregation between/management of what is in github and what is deployed.


### Alpine.js
- Am using the standard/recommended way to integrate Alpine.js from Phoenix documentation (app.js).
- Issues around initialization of Alpine in 1.7.7 .. am seeing sporadic errors in browser console when moving between pages. 

### Tailwind/DaisyUI
- Have eliminated the forms import for Tailwind as there is some mentions that this conflicts with DaisyUI
- Am still unclear if something needs to be included in app.css for DaisyUI (currently only in tailwind.config.js)
- Use of prefixes in DaisyUI breaks some 3rd party components (LiveSelect)
- CSS overall is still a nightmare to figure out, specifically, when using layered libraries - Tailwind => DaisyUI => inline styles/classes

### Javascript component libs integration (eg. DateTimePicker)
- There are two methods - via app.js (available to all pages) or page specific <script></script> 
- DateTimePicker is integrated via CDN download/script
- shepherd.js is integrated via app.js