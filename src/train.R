#' Script to train model from scratch.
#' This will automatically save the model data to model/
#' so be sure if it is fine to override the existed model data.

model.path <- file.path('model', 'mnist-model')

if (file.exists(model.path)) {
  cat(paste('[WARNING]', model.path, 'already exists. This will override the data.\n'))

  cat('Do you want to continue training? [Y/n] ')
  ok <- readLines(file('stdin'), 1)

  if (tolower(ok) != 'y') {
    cat('Terminating the process...\n')
    quit(status=1)
  }
}

library(tensorflow)
set_random_seed(1234)

source(file.path('src', 'model.R'))

model <- build_model()
train_model(model)
save_model(model)