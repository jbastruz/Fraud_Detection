library(h2o)
library(tidyverse)
library(plotly)

h2o.init(nthreads = -1)

creditcard <- read.csv("C:/Users/jeanbaptiste.astruz/iCloudDrive/Fraud\ Detection/creditcard.csv")

creditcard$Class = as.factor(as.character(creditcard$Class))
creditcard_hf <- as.h2o(creditcard)

splits <- h2o.splitFrame(creditcard_hf, 
                         ratios = c(0.4), 
                         seed = 42)

train_unsupervised  <- splits[[1]]
train_supervised  <- splits[[2]]
test <- splits[[3]]

response <- "Class"
features <- setdiff(colnames(train_unsupervised), response)


###### autoencoder (version "bottleneck") ######

model_nn <- h2o.deeplearning(x = features,
                             training_frame = train_unsupervised,
                             model_id = "model_nn",
                             autoencoder = TRUE,
                             reproducible = TRUE, #slow - turn off for real problems
                             ignore_const_cols = FALSE,
                             seed = 42,
                             hidden = c(10, 2, 10), 
                             epochs = 100,
                             activation = "Tanh")


h2o.saveModel(model_nn, path="model_nn", force = TRUE)

model_nn <- h2o.loadModel("model_nn\\model_nn")
model_nn

model_nn_2 <- h2o.deeplearning(y = response,
                               x = features,
                               training_frame = train_supervised,
                               pretrained_autoencoder  = "model_nn",
                               reproducible = TRUE, #slow - turn off for real problems
                               balance_classes = TRUE,
                               ignore_const_cols = FALSE,
                               seed = 42,
                               hidden = c(10, 2, 10), 
                               epochs = 100,
                               activation = "Tanh")


h2o.saveModel(model_nn_2, path="model_nn_2", force = TRUE)

model_nn_2 <- h2o.loadModel("model_nn_2/DeepLearning_model_R_1522827383346_53")
model_nn_2

pred <- as.data.frame(h2o.predict(object = model_nn_2, newdata = test)) %>%
  mutate(actual = as.vector(test[, 31]))

pred %>%
  group_by(actual, predict) %>%
  summarise(n = n()) %>%
  mutate(freq = n / sum(n)) 


p = plot_ly(pred[pred$predict==1 & pred$actual==1,], x= ~actual, type = "histogram", name = 'Spoted',
        marker = list(color = 'rgb(158,202,225)',
                      line = list(color = 'rgb(8,48,107)', width = 1.5))) %>%
  add_trace(data = pred[pred$predict==0 & pred$actual==1,], x = ~actual, name = 'Missed',
            marker = list(color = 'rgb(58,200,225)', line = list(color = 'rgb(8,48,107)', width = 1.5))) %>%
  layout(yaxis = list(title = 'proba'), barmode = 'stack', width = 500, xaxis = list(title = 'Fraud'))

p