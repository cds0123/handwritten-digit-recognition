library(shiny)

library(jsonlite)
library(reshape2)

source('src/helper.R')
source('src/model.R')
source('src/plots.R')
source('src/process.R')

model <- load_model()

build_counter <- function() {
  data.frame(label=rep(as.character(0:9), each=2), count=rep(0, 20), is_correct=rep(c(T, F), 10))
}

build_count_matrix <- function() {
  cm <- matrix(rep(0, 100), nrow=10)
  rownames(cm) <- 0:9
  colnames(cm) <- 0:9
  cm
}

############################################################
##    Main Shiny Server                                   ##
############################################################
server <- function(input, output, session=NA) {
  states <- reactiveValues(
    correct=0,
    attempt=0,
    pred=-1,
    prob=NA,
    counter=build_counter(),
    count_matrix=build_count_matrix()
  )

  prediction_history <- reactiveValues(
    images=list(),
    labels=list()
  )

  init <- function() {
    output$mode <- renderText('ready')
    states$pred <- -1
    states$prob <- NA
  }

  output$mode <- renderText('ready')

  # Current prediction status
  observeEvent(input$canvas_image, {
    # An image is given as 1D array, so reshape to 3D tensor
    img <- as.array(input$canvas_image)
    dim(img) <- c(280, 280, 1)

    # Resize image to (28, 28, 1)
    img <- resize_image(img)

    # R stores array column-wise but original data is intended row-wise,
    # so transpose the tensor.
    img <- aperm(img, c(2, 1, 3))

    # Create temporary image to display
    output$predicted_image <- renderImage({
      outfile <- tempfile(fileext='.jpg')
      save_image(outfile, img)

      list(id='predicted-image',
           src=outfile,
           contentType='image/jpeg',
           width=28,
           height=28,
           alt='Predicted image after resized')
    }, deleteFile=TRUE)

    prediction_history$images <- append(prediction_history$images, list(img))
    prediction_history$labels <- append(prediction_history$labels, -1)

    out <- infer(model, img)
    states$pred <- out$prediction

    states$prob <- data.frame(probability=t(out$prob), label=0:9)

    # Update the status
    output$mode <- renderText('predicted')

    # Display the prediction result
    output$prediction <- renderText(sprintf('<h3>Prediction: %d</h3>', states$pred))

    # Display probability of each class from the prediction as a bar plot
    output$prob_plot <- renderPlot(
      if (is.data.frame(states$prob)) {
        plot_prediction_plobability(states$prob)
      }
    )
    outputOptions(output, 'prob_plot')
  })

  # Action when clicked `Reset` button
  observeEvent(input$reset, { init() })

  # Count number of attempts and the correct prediction to compute accuracy
  # in the current session
  observeEvent(input$correct, {
    states$correct <- states$correct + 1
    states$attempt <- states$attempt + 1

    prediction_history$labels[length(prediction_history$labels)] <- states$pred

    # Correct number is stored in odd row
    r <- states$pred * 2 + 1
    states$counter[r, 'count'] <- states$counter[r, 'count'] + 1

    # Increment count matrix count
    cm_idx <- states$pred + 1;
    states$count_matrix[cm_idx, cm_idx] <- states$count_matrix[cm_idx, cm_idx] + 1

    output$mode <- renderText('ready')
  })

  # Action when clicked incorrect button about predicted result
  observeEvent(input$incorrect, {
    states$attempt <- states$attempt + 1
    output$mode <- renderText('actual')
  })

  # Action when send feedback of an actual label of the predicted image
  observeEvent(input$actual, {
    label <- as.integer(input$actualValue)

    # Incorrect number is stored in even row
    r <- label * 2 + 2
    states$counter[r, 'count'] <- states$counter[r, 'count'] + 1

    prediction_history$labels[length(prediction_history$labels)] <- label

    # Increment count matrix count
    cm_pred_idx <- states$pred + 1;
    cm_actual_idx <- label + 1;

    states$count_matrix[cm_actual_idx, cm_pred_idx] <-
      states$count_matrix[cm_actual_idx, cm_pred_idx] + 1

    output$mode <- renderText('ready')
  })

  output$accuracy <- renderText(
    sprintf('<h3>Overall accuracy: %5.2f%%</h3>',
            ifelse(states$attempt > 0, (states$correct / states$attempt) * 100, 0))
  )

  output$count_plot <- renderPlot(
    # Before make prediction
    if (states$attempt > 0) {
      plot_count_results(states$counter)
    }
  )

  # Display prediction-actual count matrix with data given by drawing in the current session
  output$count_matrix <- renderPlot({
    if (states$attempt > 0) {
      plot_count_heatmap(states$count_matrix)
    }
  })

  # Convert images and the associated labels as json to make them downloadable
  output$download_data <- downloadHandler(
    filename=function() { paste0('handwritten-mnist-dataset-', Sys.Date(), '.zip') },
    content=function(file) {
      # Create temporary directory to create files
      currdir <- setwd(tempdir())
      on.exit(setwd(currdir))
    
      imgs_fname <- 'images.json'
      imgs_json <- to_json(prediction_history$images)
      write(imgs_json, imgs_fname)
    
      labels_fname <- 'labels.json'
      labels_json <- toJSON(prediction_history$labels)
      write(labels_json, labels_fname)
    
      zip(file, c(labels_fname, imgs_fname))
    },
    contentType='application/json'
  )

  outputOptions(output, 'mode', suspendWhenHidden=FALSE)
}

shinyServer(server)