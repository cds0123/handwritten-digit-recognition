library(keras)

source(file.path('src', 'process.R'))

model.path <- file.path('model', 'mnist-model')

config <- list(
  epochs=10,
  batch_size=64,
  validation_split=0.2
)

#' Set training configuration.
#' Currently (epochs, batch_size, validation_split) can be updated.
set_training_config <- function(epochs=NA, batch_size=NA, validation_split=NA) {
  if (is.numeric(epochs)) {
    config$epochs <<- epochs
  }
  if (is.numeric(batch_size)) {
    config$batch_size <<- batch_size
  }
  if (is.numeric(validation_split)) {
    config$validation_split <<- validation_split
  }
}

read_training_config <- function() {
  cat(paste0('Config:',
             '\n  Epochs                 : ', config$epochs,
             '\n  Batch size             : ', config$batch_size,
             '\n  Validation split ratio : ', config$validation_split, '\n'))
}

#' Build prediction model with simple 3-layer CNN.
#'
#' @return keras CNN model
build_model <- function() {
  model <- keras_model_sequential() %>%
    layer_conv_2d(filters=16, kernel_size=c(3,3), activation='relu') %>%
    layer_max_pooling_2d(pool_size=c(2,2)) %>%
    layer_conv_2d(filters=16, kernel_size=c(3,3), activation='relu') %>%
    layer_max_pooling_2d(pool_size=c(2,2)) %>%
    layer_flatten() %>%
    layer_dense(units=128, activation='relu') %>%
    layer_dense(units=10, activation='softmax')

  model
}

#' Execute training CNN model for MNIST dataset.
#'
#' @param model Keras.models.Model instantiated with `build_model()`
#' @return A `history` object will be returned
#' @detail
#' This will train model using dataset from Keras.
#' To adjust the model to drawing on screens,
#' the pixel will be converted to {0, 255} and remove the blur pixels.
#' Batch size, a number of epoch, and validation split ratio can be
#' set using `set_training_config()`.
train_model <- function(model) {
  model %>% compile(
    loss='categorical_crossentropy',
    optimizer=optimizer_adam(),
    metrics=c('accuracy')
  )

  mnist <- dataset_mnist()
  x_train <- k_expand_dims(normalize(mnist$train$x))
  y_train <- make_categorical(mnist$train$y)
  x_test <- k_expand_dims(normalize(mnist$test$x))
  y_test <- make_categorical(mnist$test$y)

  history <- model %>%
    fit(x=x_train,
        y=y_train,
        epochs=config$epochs,
        batch_size=config$batch_size,
        validation_split=config$validation_split,
        verbose=0)

  model %>% evaluate(x_test, y_test)
  history
}

#' Save model data.
#' This is wrapper of `keras::save_model_hdf5`
#'
#' @param keras.Model
save_model <- function(model) {
  save_model_hdf5(model, model.path)
}

#' Load model data.
#' This is wrapper of `keras::load_model_hdf5`
#'
#' @return pre-trained keras model
load_model <- function() {
  load_model_hdf5(model.path)
}

#' Make inference.
#'
#' @param model Keras model used for prediction
#' @param input Input image data with (28, 28) matrix or array with length 784
#' @return list of the result and the probability of each label
infer <- function(model, input) {
  result <- predict_proba(model, convert_to_tensor(input))
  colnames(result) <- 0:9
  list(
    prob=result,
    prediction=which.max(result)-1  # output is 1-indexed but label is started from 0
  )
}
