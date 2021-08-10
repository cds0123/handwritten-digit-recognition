# Hand-written digit recognition

This is a bare simple digit recognition app built using `shiny`.

[Demo(shinyapp)](https://cds0123.shinyapps.io/handwritten-digit-recognition/) (This may take time to first access to start up)

## 1 Environment setting

This project uses following languages and packages.

```
R==3.6.3
python==3.8.10

# R packages
ggplot2==3.3.5
jpeg==0.1.8.1
jsonlite==1.7.2
keras==2.4.0
reshape2==1.4.4
reticulate==1.20
shiny==1.6.0
tensorflow==2.5.0

# python packages
numpy==1.19.5
tensorflow==2.5.0

# npm package
uglify-js@3.14.1  # used for minify
```

Note that in order to run `tensorflow`, it must be installed with `conda` or `virtualenv`
and set python path to it accordingly.

## 2 Execution

### 2.1 Local model training

Run the `src/train.R`. You can run it on _RStudio_ IDE or terminal (e.g., "`Rscript src/train.R`" in Ubuntu).
This will create `model/` directory and the web app will search model data from it.

### 2.2 Web app

Open the `server.R` file and click the `Run App` button on _RStudio_.

If you do not have _RStudio_, you can run `app.R` script as following instead (not recommended).

```sh
# Example (Ubuntu)
# In order to stop the process, may need to send SIGTERM.
$ Rscript app.R &
```

### 2.3 Update model

Users can write their own digit in the canvas, and the model predict the number accordingly.
It records scores in the session.
Furthermore, we can download the images and the labels (you must provide correct labels) drawn during the session.
Thus, we can use them to improve model to adjust your writing habbit more.

### Reference

[1] Y. LeCun, L. Bottou, Y. Bengio and P. Haffner: Gradient-Based Learning Applied to Document Recognition, Proceedings of the IEEE, 86(11):2278-2324, November 1998,
