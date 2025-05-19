# Render any materials relying on googlesheets4 package

# Make sure to set appropriate secrets to allow auto-rendering to happen.
# This can be done via settings > secrets > actions menus.
# Key should be generated in json format via the https://console.cloud.google.com/
# interface, by creating a key that can be used by a Google Service Account.

# Note that credentials need to be created in the pull_request.yml or
# render-all.yml workflows first. Any Google Sheets in question must also be
# shared with the Google Service Account.

# ------------- Authenticate --------------

library(googlesheets4)

gs4_deauth()
gs4_auth(
  token = gargle::credentials_service_account(path = paste0(
    ".secrets/", grep(".json$", list.files(".secrets"), value = TRUE)
  ),
  scopes = "https://www.googleapis.com/auth/spreadsheets")
)

rmarkdown::render_site()
