library(shiny)

source('src/components.R')

ui <- navbarPage(
  'Hand-Written Digit Recognition',
  theme=shinythemes::shinytheme('flatly'),
  tabPanel(
    'App',
    tags$head(
      tags$link(rel='stylesheet', type='text/css', href='css/main.css')
    ),
    div(
      id='main-app',
      div(
        style='width:90%;max-width:1200px;margin:auto;',
        titlePanel('Hand-Written Digit Recognition'),
      ),
      component.data_download,
      div(
        style='display:flex;flex-direction:row;flex-wrap:wrap;width:90%;max-width:1200px;margin:auto;',
        component.canvas,
        component.result,
      ),
    )
  ),
  tabPanel(
    'About',
    component.about,
    tags$body(tags$script(src='js/main.min.js'))
  ),
  collapsible=TRUE
)