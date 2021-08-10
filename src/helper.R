library(jpeg)

save_image <- function(path, img) {
  # Convert to numeric in case the canvas is empty
  img <- apply(img, c(1,2), as.numeric)
  
  # Normalize to make it range [0, 1]
  if (max(img) > 1) {
    img = img / max(img)
  }
  writeJPEG(img, path)
}