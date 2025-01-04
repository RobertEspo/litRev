# Render one rep max shiny app ------------------------------------------------
#
# - renders one rep max shiny app
# 
# -----------------------------------------------------------------------------

# libs -----------------------------------------------------------------

library(shiny)
library(shinylive)
library(httpuv)
library(here)

# -----------------------------------------------------------------------------

shinylive::export(appdir = ".",
                  destdir = "docs"
)

httpuv::runStaticServer("docs")