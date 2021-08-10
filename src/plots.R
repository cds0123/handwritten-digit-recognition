library(ggplot2)

#' Plot prediction probabilities for each label.
#' 
#' @param prob data.frame of probabilities.
#'             This must contain:
#'               - label
#'               - probability
#' @return bar plot
plot_prediction_plobability <- function(prob) {
  ggplot(prob, aes(x=reorder(label, probability), y=probability)) +
    geom_bar(stat='identity', width=0.7) +
    scale_y_continuous(limits=c(-.005, 1.03), expand=c(0, 0)) +
    labs(title='Prediction Confidence') +
    xlab('Label') +
    ylab('Confidence') +
    theme(
      title=element_text(size=18),
      axis.title.x=element_text(size=15),
      axis.title.y=element_text(size=15),
      axis.text.x=element_text(size=12),
      axis.text.y=element_text(size=14)
    ) +
    coord_flip()
}

#' Plot total counts of success/failures.
#' 
#' @param counter data.frame of probabilities.
#'                This must contain:
#'                  - label     : factor
#'                  - count     : integer/numeric
#'                  - is_correct: logical
#' @return bar plot
plot_count_results <- function(counter) {
  ggplot(counter, aes(x=label, y=count, fill=is_correct)) +
    geom_col(position='dodge') +
    scale_y_continuous(limits=c(0, NA)) +
    scale_fill_discrete(limits=c(FALSE, TRUE), labels=c('Failure', 'Success')) +
    labs(title='Prediction Count') +
    xlab('Actual label') +
    ylab('Count') +
    guides(fill=guide_legend('Prediction result', reverse=TRUE)) +
    theme(
      title=element_text(size=18),
      axis.title.x=element_text(size=14),
      axis.title.y=element_text(size=14),
      axis.text.x=element_text(size=12),
      axis.text.y=element_text(size=12),
      legend.title=element_text(size=12)
    )
}

#' Plot prediction probabilities for each label.
#' 
#' @param count_matrix data.frame/matrix of prediction/actual count matrix.
#' @return heatmap plot
plot_count_heatmap <- function(count_matrix) {
  df <- melt(count_matrix)
  # All labels {0:9} should be treated as factor
  df$Var1 <- as.factor(df$Var1)
  df$Var2 <- as.factor(df$Var2)

  df$value <- as.integer(df$value)

  ggplot(df, aes(y=Var1, x=Var2)) +
    geom_raster(aes(fill=value), stat='identity') +
    geom_text(df, mapping=aes(y=Var1, x=Var2, label=value)) +
    scale_x_discrete(position='top', breaks=0:9, labels=0:9, expand=c(0,0)) +
    scale_y_discrete(breaks=0:9, labels=0:9, expand=c(0, 0), limits=rev) +
    scale_fill_viridis_c() +
    coord_equal() +
    labs(title='Prediction-Actual Count Matrix Heatmap') +
    xlab('Predicted Label') +
    ylab('Actual Label') +
    guides(fill=guide_legend('Count', reverse=TRUE)) +
    theme(
      title=element_text(size=18),
      axis.title.x=element_text(size=14),
      axis.title.y=element_text(size=14),
      axis.text.x=element_text(size=12),
      axis.text.y=element_text(size=12),
      legend.title=element_text(size=12)
    )
}