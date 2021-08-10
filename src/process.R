library(keras)
library(reticulate)

np <- import('numpy')
json <- import('json')

normalize <- function(x) {
  k_cast(x, 'float32') / 255
}

#' Filter pixel by threshold.
#' This is used to remove blurred edges.
#' This is specifically used for targeting to canvas drawing
#' which has solid edges.
#'
#' @param x Input tensor of image(s)
#' @param threshold 1 if the pixel value is larger than this otherwise 0
#' @return {0, 1} tensor with the same shape as input
filterpixel <- function(x, threshold=10) {
  # For the drawing on the monitor, it can be either 0 or 255,
  # so just filter by threshold and set either 0 or 1 accordingly.
  k_cast((x > threshold), 'float32')
}

make_categorical <- function(y) {
  to_categorical(y, 10)
}

#' Resize image 2D matrix or 3D tensor to (28, 28, 1)
resize_image <- function(img) {
  if (length(dim(img)) == 2) {
    img <- k_expand_dims(img)
  }
  image_array_resize(img, 28, 28, 'channels_last')
}

#' Convert input image data (28x28) to tensor.
#'
#' @param input Input 3D image data with shape (28, 28, 1)
#' @return 4D tensor with shape (1, 28, 28, 1)
convert_to_tensor <- function(input) {
  if (!all.equal(dim(input), c(28, 28, 1))) {
    stop('Given tensor does not match expected shape (28, 28, 1)')
  }

  k_expand_dims(input, 1) %>%
    normalize()
}

#' Convert image to JSON.
#' This is used instead of `jsonlite` because the image data is EagerTensor,
#' therefore it must be treated as python object.
to_json <- function(imgs) {
  json$dumps(lapply(imgs, np$ndarray$tolist))
}

#' Convert RGB formatted image data to grayscale data.
#' To simplify, this only compute mean in the third dimension,
#' since, the original data only has black and white,
#' so no need to apply luma or other method.
rgb_to_grayscale <- function(img) {
  apply(img, c(1, 2), mean)
}