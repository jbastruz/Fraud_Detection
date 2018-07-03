# Fraud_Detection
A program based on semi-supervised learning to detect CerditCard Fraud Detection on Very Unbalanced database

Notice this projet need to learn on a database to be used. It was designed especialy for very unbalanced databases like database for fraud detection. The training part take place in the file "Training.R". This part will create, train and save the machine learning models.

To use the trained machine learning, you just have to run the file "server.R". This file will execute a R Shiny program. The purpose was to make it as easy as possible to use. You just have to download your file (.csv or .txt) and run. the program will automatically separate the detected frauds from the rest.

(PS: mind to defind correctly the name of each model)
