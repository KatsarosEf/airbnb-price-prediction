library(stringr)
library(car)
library(faraway)
library(ggplot2)
library(corrgram)
library(stringr)
library(leaps)
library(corrgram)
library(gridExtra)
library(corrplot)


# We read the data into a data frame called airbnb.
airbnb = read.csv("listings.csv")

cat('
    ----------------
    |Data Wrangling|
    ----------------
    ')

# We count the number NA's for each variable.
# We exclude the variables where the majority of values are NA's. Four variables are excluded.
countNA = 0
for (i in 1:ncol(airbnb)){
  
  countNA[i] = sum(is.na(airbnb[, i]))
  
}
airbnb = airbnb[, -which(countNA > 14000)]


# We exclude variables that do not provide relevant information in order to predict the price of listings. 
# Variable neighbourhood_cleansed is renamed to neighbourhood.
# We keep the following variables:
variables = c('neighbourhood_cleansed',
              'property_type',
              'room_type',
              'accommodates',
              'bathrooms',
              'bedrooms',
              'beds',
              'price',
              'cleaning_fee',
              'availability_30',
              'number_of_reviews',
              'review_scores_rating',
              'reviews_per_month')

airbnb = airbnb[, variables]
colnames(airbnb)[1] = 'neighbourhood'

# Observations that contain NAs in at least on of the columns, are excluded. 
airbnb = na.omit(airbnb)

# Variables price and cleaning_fee need to be converted to numeric, since they are of class factor. 
airbnb$price = as.character(airbnb$price)
airbnb$price = str_replace(airbnb$price, ",", "")
airbnb$price = as.numeric(str_sub(airbnb$price, 2))

airbnb$cleaning_fee = as.character(airbnb$cleaning_fee)
airbnb$cleaning_fee = str_replace(airbnb$cleaning_fee, ",", "")
airbnb$cleaning_fee = as.numeric(str_sub(airbnb$cleaning_fee, 2))

indices = which(is.na(airbnb$cleaning_fee))
airbnb[indices, "cleaning_fee"] = 0

# We remove levels of property_type with less than or equal to five observations. There are 10 such levels.
table(airbnb$property_type)
airbnb = airbnb[!as.numeric(airbnb$property_type) %in% 
                  which(table(airbnb$property_type) <= 5), ]    

airbnb$property_type = droplevels(airbnb$property_type)

cat('
    ---------------------------
    |Exploratory Data Analysis|
    ---------------------------
    ')

# Side-by-side boxplots of logarithm of price, for each neighbourhood.
ggplot(airbnb, 
       aes(x = as.numeric(airbnb$neighbourhood), 
           y = log(airbnb$price), 
           fill = airbnb$neighbourhood)) + 
  geom_boxplot(alpha = .6, outlier.alpha = .4) +
  scale_y_continuous(name = "Logarithm of Price") + 
  scale_x_discrete(name = "Neighbourhoods") + 
  theme_minimal() +
  theme(axis.title.x = element_text(size = 12),
        axis.title.y = element_text(size = 12),
        axis.text.y = element_text(size = 10),
        legend.position = "bottom") + 
  theme(legend.text = element_text(size = 8)) + 
  labs(fill = "")

# Correlograms represent pairwise correlations between each variable.
col = colorRampPalette(c("#BB4444", "#EE9988", "#FFFFFF", "#77AADD", "#4477AA"))
corrplot(cor(as.matrix(airbnb[, 4:ncol(airbnb)])), method = "color", col = col(200),  
         type = "upper", order = "hclust", 
         addCoef.col = "black", 
         tl.col = "black", tl.srt = 45, 
         diag = FALSE)

# Boxplots of logarithm of price, for each property type.
ggplot(airbnb, 
       aes(x = as.numeric(airbnb$property_type), 
           y = log(airbnb$price), 
           fill = airbnb$property_type)) + 
  geom_boxplot(alpha = .6, outlier.alpha = 0.4) + 
  scale_y_continuous(name = "Logarithm of Price") + 
  scale_x_discrete(name = "Property Type") + 
  theme_minimal() +
  theme(axis.text.y = element_text(size = 10),
        axis.title.x = element_text(size = 11),
        axis.title.y = element_text(size = 11),
        legend.position = "bottom",
        legend.text = element_text(size = 8)) + 
  scale_fill_brewer(palette = "Paired") + 
  labs(fill = "")

#Boxplots of logarithm of price, for each room type.
ggplot(airbnb, 
       aes(x = as.numeric(airbnb$room_type), 
           y = log(airbnb$price), 
           fill = airbnb$room_type)) + 
  geom_boxplot(alpha = 0.6, outlier.alpha = 0.4) + 
  scale_y_continuous(name = "Logarithm of Price") + 
  scale_x_discrete(name = "Room Type") +
  theme_minimal() +
  theme(axis.text.y = element_text(size = 10), 
        axis.title.x = element_text(size = 11),
        axis.title.y = element_text(size = 11),
        legend.text = element_text(size = 9),
        legend.position = "bottom") +
  scale_fill_brewer(palette = "Set1") +
  labs(fill = "")

# Histogram of price.
ggplot(data = airbnb, 
       aes(airbnb$price)) + 
  geom_histogram(bins = 50, 
                 col = "#000000", 
                 fill = "#99FFFF", 
                 alpha = .5) + 
  labs(x = "Price", y = "Frequency") + 
  scale_x_continuous(breaks = c(seq(0, 800, 200),1000, 1500, 2000)) +
  scale_y_continuous(breaks = c(seq(0, 4000, 1000), 4600)) +
  theme_minimal() + 
  theme(axis.text.x = element_text(size = 10), 
        axis.text.y = element_text(size = 10),
        axis.title.x = element_text(size = 11),
        axis.title.y = element_text(size = 11))

#Scatterplots of logarithm of price with respect to accommodates, bathrooms, bedrooms, and beds, respectively.
p1 = ggplot(airbnb, 
            aes(x = airbnb$accommodates, 
                y = log(airbnb$price))) + 
  geom_point(alpha = 0.4) + 
  labs(y = 'Logarithm of Price', x = 'Accommodates') +
  theme_minimal() +
  scale_x_continuous(breaks = seq(1, 17, 2)) +
  theme(axis.text.x = element_text(size = 10),
        axis.text.y = element_text(size = 10),
        axis.title.x = element_text(size = 12),
        axis.title.y = element_text(size = 12))

p2 = ggplot(airbnb, 
            aes(x = airbnb$bathrooms, 
                y = log(airbnb$price))) + 
  geom_point(alpha = 0.4) + 
  theme_minimal() +
  labs(x = 'Bathrooms', y = '') +
  theme(axis.text.x = element_text(size = 10),
        axis.text.y = element_text(size = 10),
        axis.title.x = element_text(size = 12),
        axis.title.y = element_text(size = 12))

p3 = ggplot(airbnb, 
            aes(x = airbnb$bedrooms, 
                y = log(airbnb$price))) + 
  geom_point(alpha = 0.4) + 
  theme_minimal() +
  labs(x = 'Bedrooms', y = 'Logarithm of Price') +
  scale_x_continuous(breaks = seq(0, 10, 2)) +
  theme(axis.text.x = element_text(size = 10),
        axis.text.y = element_text(size = 10),
        axis.title.x = element_text(size = 12),
        axis.title.y = element_text(size = 12))

p4 = ggplot(airbnb, 
            aes(x = airbnb$beds, 
                y = log(airbnb$price))) + 
  geom_point(alpha = 0.4) + 
  theme_minimal() +
  labs(x = 'Beds', y = '') +
  scale_x_continuous(breaks = seq(0, 16, 2)) +
  theme(axis.text.x = element_text(size = 10),
        axis.text.y = element_text(size = 10),
        axis.title.x = element_text(size = 12),
        axis.title.y = element_text(size = 12))

grid.arrange(p1,p2,p3,p4)

# Scatterplot of logarithm of price and cleaning fee.
p5 = ggplot(airbnb, 
            aes(x = airbnb$cleaning_fee, 
                y = log(airbnb$price))) + 
  geom_point(alpha = 0.4) + 
  theme_minimal() +
  labs(x = 'Cleaning Fee', y = 'Logarithm of Price') +
  theme(axis.text.x = element_text(size = 12),
        axis.text.y = element_text(size = 12),
        axis.title.x = element_text(size = 14),
        axis.title.y = element_text(size = 14))
p5

cat('
    --------------------
    |Variable Selection|
    --------------------
    ')
# Check for significance of each variable. 
# We use the drop1() function. Variable number_of_reviews is not statistically significant. 
# The variable is removed from the model. The p-value is 0.5185.
initialModel = lm(price ~ neighbourhood + 
                    property_type + 
                    room_type + 
                    accommodates + 
                    bathrooms + 
                    bedrooms + 
                    beds + 
                    cleaning_fee + 
                    availability_30 + 
                    number_of_reviews + 
                    review_scores_rating + 
                    reviews_per_month, data = airbnb)

drop1(initialModel, test = "F")
initialModel2 = lm(price ~ accommodates + 
                     bathrooms + 
                     bedrooms + 
                     beds + 
                     cleaning_fee + 
                     availability_30 + 
                     review_scores_rating + 
                     reviews_per_month, data = airbnb)

# Function vif() examines for multicolinearity between regressors.
vif(initialModel2)

# The leaps() function employs an exhaustive search and reports the adjusted R^2. 
# It works only for quantitative variables, so these are extracted in a data frame called airbnbQualitative.
price = airbnb$price
airbnbQualitative = airbnb[ ,-c(1,2,3,8,11)]
fullModelQualitative = lm(price ~ ., data = airbnbQualitative)
summary(fullModelQualitative)

modelMatrixQual = model.matrix(fullModelQualitative)[ ,-1]

adjustedR2 = leaps(modelMatrixQual, price, method = 'adjr2', nbest = 30)
maxadjr(adjustedR2, 25)


# The selected model from leaps() contains four quantitative variables, 
# specifically, accommodates, bedrooms, cleaning_fee and availability_30. 
# It explains 0.41% of variance in the data. The selected model is combined with the three remaining factor variables.
airbnb = cbind(airbnb$neighbourhood, 
               airbnb$property_type, 
               airbnb$room_type, 
               airbnbQualitative[, c(1,3,5,6)])

colnames(airbnb) = c('neighbourhood', 
                     'property_type', 
                     'room_type', 
                     'accommodates', 
                     'bedrooms', 
                     'cleaning_fee', 
                     'availability_30')

airbnb$price = price

# The significance of each factor variable with respect to the increase of the adjusted R^2 is examined. 
# It is known that all three factor variables are significant as shown from the output of drop1() function. 
# We remove the variable that does not increase the adjusted R^2 significantly.       
# First, variable room_type is removed.
fullModel = lm(price ~ ., data = airbnb)
summary(fullModel)$adj.r.squared

cat('Remove room_type')
reducedModel1 = lm(price ~ accommodates + 
                     bedrooms + 
                     cleaning_fee + 
                     availability_30 + 
                     neighbourhood + 
                     property_type, data = airbnb)
summary(reducedModel1)$adj.r.squared

# The removal of property_type follows.
reducedModel2 = lm(price ~ accommodates + 
                     bedrooms + 
                     cleaning_fee + 
                     availability_30 + 
                     neighbourhood + 
                     room_type, data = airbnb)
summary(reducedModel2)$adj.r.squared

# Finally, we remove variable neighbourhood.
reducedModel3 = lm(price ~ accommodates + 
                     bedrooms + 
                     cleaning_fee + 
                     availability_30 + 
                     property_type + 
                     room_type, data = airbnb)
summary(reducedModel3)$adj.r.squared

# Variable property_type is removed from the model, since it provides the least increase in adjusted R^2. 
airbnb = airbnb[, -2]
fullModel = reducedModel2

# We examine which interactions between quantitative and qualitative variables are statistically significant. 
# We decided to keep two interactions; those that result in the largest decrease in Residual Sum of Squares (RSS).
anova(update(fullModel, . ~ . + neighbourhood:cleaning_fee))[7, ]
anova(update(fullModel, . ~ . + neighbourhood:availability_30))[7, ]
anova(update(fullModel, . ~ . + room_type:accommodates))[7, ]
anova(update(fullModel, . ~ . + room_type:cleaning_fee))[7, ]
anova(update(fullModel, . ~ . + room_type:availability_30))[7, ]

# The model containing the interaction neighbourhood:cleaning_fee provided the largest decrease in RSS (565551). 
# We add the interaction to the model.
fullModel = update(fullModel, . ~ . + neighbourhood:cleaning_fee)

# The model with the interaction neighbourhood:availability_30 results in the largest decrease in RSS,
# given that we have added neighbourhood:cleaning_fee. 
# The model is updated by adding this interaction as well.
anova(update(fullModel, . ~ . + neighbourhood:availability_30))[8, ]
anova(update(fullModel, . ~ . + room_type:accommodates))[8, ]
anova(update(fullModel, . ~ . + room_type:cleaning_fee))[8, ]
anova(update(fullModel, . ~ . + room_type:availability_30))[8, ]

fullModel = update(fullModel, . ~ . + neighbourhood:availability_30)

# The model explains 51.7% of variance in the data. The Q-Q plot indicates large deviations from normality.
summary(fullModel)$adj.r.squared
qqPlot(fullModel$residuals, 
       ylab = "", 
       xlab = "")
mtext("Residuals", side = 2, line = 2.6, cex = 1)
mtext("Normal Quantiles", side = 1, line = 2.6, cex = 1)

# We use the log transformation for the response. 
# The following plot represents the Q-Q plot of the residuals after the transformation. 
# Although the residuals seem to be more normally distributed, deviation from normality is still apparent. 
# The adj. R^2 is equal to 0.59. For the rest of the analysis, the log transformation is used for the response.
fullModelLog = lm(log(price) ~ accommodates + 
                    bedrooms + 
                    cleaning_fee + 
                    availability_30 + 
                    neighbourhood + 
                    room_type + 
                    neighbourhood:cleaning_fee + 
                    neighbourhood:availability_30 , data = airbnb)
summary(fullModelLog)$adj.r.squared
qqPlot(fullModelLog$residuals, 
       ylab = "", 
       xlab = "")
mtext("Residuals", side = 2, line = 2.6, cex = 1)
mtext("Normal Quantiles", side = 1, line = 2.6, cex = 1)

cat('
    -----------------
    |Model Selection|
    -----------------
    ')

# 21 models that contain different combinations of variables with interactions, 
# polynomial terms of second order, and logarithm transformations are defined.
models = c(log(price) ~ accommodates + # 1
             bedrooms + 
             cleaning_fee + 
             availability_30 + 
             neighbourhood + 
             room_type,
           log(price) ~ poly(accommodates, 2) + # 2
             bedrooms + 
             cleaning_fee + 
             availability_30 + 
             neighbourhood + 
             room_type,
           log(price) ~ accommodates + # 3
             poly(bedrooms, 2) + 
             cleaning_fee + 
             availability_30 + 
             neighbourhood + 
             room_type,
           log(price) ~ poly(accommodates, 2) + # 4
             poly(bedrooms, 2) + 
             cleaning_fee + 
             availability_30 + 
             neighbourhood + 
             room_type,
           log(price) ~ log(accommodates) + # 5
             bedrooms + 
             cleaning_fee + 
             availability_30 + 
             neighbourhood + 
             room_type,
           log(price) ~ accommodates + # 6
             log(bedrooms + 1) + 
             cleaning_fee + 
             availability_30 + 
             neighbourhood + 
             room_type,
           log(price) ~ log(accommodates) + # 7
             log(bedrooms + 1) + 
             cleaning_fee + 
             availability_30 + 
             neighbourhood + 
             room_type,
           log(price) ~ accommodates + # 8
             bedrooms + 
             cleaning_fee + 
             availability_30 + 
             neighbourhood + 
             room_type + 
             neighbourhood:cleaning_fee,
           log(price) ~ poly(accommodates, 2) + # 9
             bedrooms + 
             cleaning_fee + 
             availability_30 + 
             neighbourhood + 
             room_type + 
             neighbourhood:cleaning_fee,
           log(price) ~ accommodates + # 10
             poly(bedrooms, 2) + 
             cleaning_fee + 
             availability_30 + 
             neighbourhood + 
             room_type +
             neighbourhood:cleaning_fee,
           log(price) ~ poly(accommodates, 2) + # 11
             poly(bedrooms, 2) + 
             cleaning_fee + 
             availability_30 + 
             neighbourhood + 
             room_type + 
             neighbourhood:cleaning_fee,
           log(price) ~ log(accommodates) + # 12
             bedrooms + 
             cleaning_fee + 
             availability_30 + 
             neighbourhood + 
             room_type + 
             neighbourhood:cleaning_fee,
           log(price) ~ accommodates + # 13
             log(bedrooms + 1) + 
             cleaning_fee + 
             availability_30 + 
             neighbourhood + 
             room_type + 
             neighbourhood:cleaning_fee,
           log(price) ~ log(accommodates) + # 14
             log(bedrooms + 1) + 
             cleaning_fee + 
             availability_30 + 
             neighbourhood + 
             room_type + 
             neighbourhood:cleaning_fee,
           log(price) ~ accommodates + # 15
             bedrooms + 
             cleaning_fee + 
             availability_30 + 
             neighbourhood + 
             room_type + 
             neighbourhood:cleaning_fee +
             availability_30:neighbourhood,
           log(price) ~ poly(accommodates, 2) + # 16
             bedrooms + 
             cleaning_fee + 
             availability_30 + 
             neighbourhood + 
             room_type + 
             neighbourhood:cleaning_fee +
             availability_30:neighbourhood,
           log(price) ~ accommodates + # 17
             poly(bedrooms, 2) + 
             cleaning_fee + 
             availability_30 + 
             neighbourhood + 
             room_type +
             neighbourhood:cleaning_fee +
             availability_30:neighbourhood,
           log(price) ~ poly(accommodates, 2) + # 18
             poly(bedrooms, 2) + 
             cleaning_fee + 
             availability_30 + 
             neighbourhood + 
             room_type +
             neighbourhood:cleaning_fee +
             availability_30:neighbourhood,
           log(price) ~ log(accommodates) + # 19
             bedrooms + 
             cleaning_fee + 
             availability_30 + 
             neighbourhood + 
             room_type + 
             neighbourhood:cleaning_fee +
             availability_30:neighbourhood,
           log(price) ~ accommodates + # 20
             log(bedrooms + 1) + 
             cleaning_fee + 
             availability_30 + 
             neighbourhood + 
             room_type + 
             neighbourhood:cleaning_fee +
             availability_30:neighbourhood,
           log(price) ~ log(accommodates) + # 21
             log(bedrooms + 1) + 
             cleaning_fee + 
             availability_30 + 
             neighbourhood + 
             room_type + 
             neighbourhood:cleaning_fee +
             availability_30:neighbourhood)

# Function ModelSelectionCV performs Cross Validation in order to select the model that predicts more accurately 
# in unseen/new/test data, with respect to three different metrics. 
# The following metrics are used: Root Mean Squared Error (RMSE), Mean Absolute Error (MAE), and Median Absolute Error (MedAE). 
# The number of folds and repeats is defined by the user. We have chosen to perform 10-fold CV, repeated 20 times. 
ModelSelectionCV = function(data, response, models, numFolds = 10, repeats = 1){
  
  repeatsRMSE = matrix(0, nrow = length(models), ncol = repeats)
  repeatsMedAE = matrix(0, nrow = length(models), ncol = repeats)
  repeatsMAE = matrix(0, nrow = length(models), ncol = repeats)
  
  for (time in 1:repeats){
    
    set.seed(time)
    
    # Randomly shuffle the data
    samp = sample(nrow(data))
    dataShuffled = data[samp, ]
    
    # Create 10 equally size folds
    folds = cut(seq(1, nrow(dataShuffled)), breaks = numFolds, labels = FALSE)
    
    RMSE = matrix(0, nrow = length(models), ncol = numFolds)
    MedAE = matrix(0, nrow = length(models), ncol = numFolds)
    MAE = matrix(0, nrow = length(models), ncol = numFolds)
    
    cat("\n",numFolds, "-Fold CV", " || Repeat ", time, sep = "")
    cat("\n----------------------\n")
    for(model in 1:length(models)){
      
      cat("Model", model,"\n")
      
      for(fold in 1:numFolds){
        
        testIndices = which(folds == fold, arr.ind = TRUE)
        testData = dataShuffled[testIndices, ]
        trainData = dataShuffled[-testIndices, ]
        
        modelTrain = lm(models[[model]], data = trainData, singular.ok = FALSE)
        
        predictions = exp(predict(modelTrain, testData))
        n = nrow(testData) 
        k = length(coef(modelTrain))
        RSS = sum((testData[, response] - predictions)^2)
        
        RMSE[model, fold] = sqrt(RSS/n)
        MedAE[model, fold] = median(abs(testData[, response] - predictions))
        MAE[model, fold] = mean(abs(testData[, response] - predictions))
      }
      
    }
    
    repeatsRMSE[, time] = rowMeans(RMSE)
    repeatsMedAE[, time] = rowMeans(MedAE)
    repeatsMAE[, time] = rowMeans(MAE)
  }
  
  meansRMSE = rowMeans(repeatsRMSE)    
  meansMedAE = rowMeans(repeatsMedAE)    
  meansMAE = rowMeans(repeatsMAE)    
  
  bestModelRMSE = which.min(meansRMSE)
  bestModelMedAE = which.min(meansMedAE)
  bestModelMAE = which.min(meansMAE)
  
  cat("\n\n Model number:", bestModelRMSE,
      "\n RMSE", meansRMSE[bestModelRMSE],
      "\n Model: ", format(models[[bestModelRMSE]]))
  
  cat("\n\n Model number:", bestModelMedAE,
      "\n MedAE", meansMedAE[bestModelMedAE],
      "\n Model:", format(models[[bestModelMedAE]]))
  
  cat("\n\n Model number:", bestModelMAE,
      "\n MAE", meansMAE[bestModelMAE],
      "\n Model:",format(models[[bestModelMAE]]), "\n\n")
}

ModelSelectionCV(airbnb, 'price', models, numFolds = 10, repeats = 20)


# We select the best model with respect to MAE. 
# The reason for this is that MAE is an easily interpretable metric and more robust to outliers compared to RMSE. 
# The model contains a polynomial term of second order in accommodates and an interaction 
# between neighborhood and cleaning_fee. MAE is equal to 31.05 euros.  

cat('
    ----------------------------------
    |Assumptions of Linear Regression|
    ----------------------------------
    ')

# After choosing the best model with respect to MAE, the assumptions of Linear Regression are examined. 
# Although the assumption of constant variance holds, the residuals are not normally distributed.
model = lm(log(price) ~ poly(accommodates, 2) + 
             bedrooms + 
             +    cleaning_fee + 
             availability_30 + 
             neighbourhood + 
             room_type + 
             neighbourhood:cleaning_fee, data = airbnb)
summary(model)$adj.r.squared
qqPlot(model$residuals, 
       ylab = "", 
       xlab = "")
mtext("Residuals", side = 2, line = 2.6, cex = 1)
mtext("Normal Quantiles", side = 1, line = 2.6, cex = 1)

resVarianceDF = data.frame(residuals = model$residuals, fittedValues = model$fitted.values)
ggplot(resVarianceDF, aes(x = model$fitted.values, y = model$residuals)) + 
  geom_point(alpha = 0.4) + 
  labs(x = 'Residuals', y = 'Fitted Values') +
  theme_minimal() +
  theme(text = element_text(size = 13), 
        axis.text.x = element_text(size = 13), 
        axis.text.y = element_text(size = 13))

# We examine the influence and leverage of observations in the fitted model. 
# For this, we calculate the Cooks Distance. We set as a threshold the value 4/n, where n the number 
# of observations in the data set. We find 744 observations with Cooks Distance greater than the aforementioned threshold.
cooksDistance = cooks.distance(model)
numOutliersCD = sum(cooksDistance > 4 / length(cooksDistance))

# Due to the large number of influencial observations returned by Cooks Distance, 
# we decided to also examine the studentized residuals. First, we calculate the studentized residuals 
# for each observation in the data set. Those with values greater than the absolute value of three are removed. 
# The new data frame (without the outliers) is called airbnb2. The following plot illustrates the studentized residuals. 
# Those indicated with red have an absolute value greater than or equal to three.
studentizedRes = rstudent(model)
studResAbs3 = studentizedRes[abs(studentizedRes) >= 3]
studentizedResDF = data.frame(Residuals = studentizedRes, index = 1:nrow(airbnb))
studentizedResDF$colour = ifelse(abs(studentizedResDF$Residuals) > 3, 'red', 'black')
ggplot(studentizedResDF, aes(index, Residuals)) + 
  geom_point(colour = studentizedResDF$colour, alpha = 0.4) + 
  geom_line(aes(x = index, y = 3),  size = 1, linetype = 'dashed') +
  geom_line(aes(x = index, y = -3),  size = 1, linetype = 'dashed') + 
  labs(y = 'Studentized Residuals', x = 'Index') +
  theme_minimal() +
  theme(text = element_text(size = 13),
        axis.text.x = element_text(size = 13),
        axis.text.y = element_text(size = 13)) + 
  scale_y_continuous(breaks = c(-9, -6, -3, 0, 3, 6, 9))

airbnb2 = airbnb[abs(rstudent(model)) < 3, ]

# We fit the model again using the airbnb2 data set. The adj. R^2 increase, and it is equal to 0.633. 
# As it can be seen from the following plots, the residuals are normally distributed
# and the assumption of constant variance holds.
model2 = lm(log(price) ~ poly(accommodates, 2) +
              bedrooms + 
              cleaning_fee + 
              availability_30 + 
              neighbourhood + 
              room_type +
              neighbourhood:cleaning_fee, data = airbnb2)
summary(model2)$adj.r.squared
qqPlot(model2$residuals, 
       ylab = "", 
       xlab = "")
mtext("Residuals", side = 2, line = 2.6, cex = 1)
mtext("Normal Quantiles", side = 1, line = 2.6, cex = 1)

resVarianceDF = data.frame(residuals = model2$residuals, fittedValues = model2$fitted.values)
ggplot(resVarianceDF, aes(x = model2$fitted.values, y = model2$residuals)) + 
  geom_point(alpha = 0.4) + 
  labs(x = 'Residuals', y = 'Fitted Values') +
  theme_minimal() +
  theme(text = element_text(size = 13), 
        axis.text.x = element_text(size = 13), 
        axis.text.y = element_text(size = 13))

cat('
    ------------------
    |Model Validation|
    ------------------
    ')

# Function ModelValidationCV perfroms 10-fold CV in order to examine how well the model predicts the price 
# in unseen/new data. First, observations that correspond to studentized residuals with absolute value 
# greater than three are extracted. In each of the 10 repetitions, the model is fitted in the train set that 
# contains no outliers. A sample of the outliers is added in the test set, so that the latter represents reality, 
# that is, contains both normal and outlier observations. MAE is equal to 31.11 euros, whereas the RMSE and MedAE 
# are 52.64 and 19.88 euros respectively.
ModelValidationCV = function(data, response, model, numFolds = 10, seed = 100){
  
  outliers = data[abs(rstudent(model)) >= 3, ]
  dataNoOutliers = data[abs(rstudent(model)) < 3, ]
  numOutliers = nrow(outliers)
  percentOutliers = numOutliers / nrow(data)
  
  set.seed(seed)
  samp = sample(nrow(dataNoOutliers))
  dataShuffled = dataNoOutliers[samp, ]
  
  # Create 10 equally size folds
  folds = cut(seq(1, nrow(dataNoOutliers)), breaks = numFolds, labels = FALSE)  
  
  RMSE = numeric(numFolds)
  MedAE = numeric(numFolds)
  MAE = numeric(numFolds)
  
  for(fold in 1:numFolds){
    
    testIndices = which(folds == fold, arr.ind = TRUE)
    testData = dataShuffled[testIndices, ]
    trainData = dataShuffled[-testIndices, ]
    sampOutliers = sample(nrow(outliers), round(percentOutliers*nrow(testData)))
    chooseOutliers = outliers[sampOutliers, ]
    testData = rbind(testData, chooseOutliers)
    
    modelTrain = lm(log(price) ~ poly(accommodates, 2) +
                      bedrooms + 
                      cleaning_fee + 
                      availability_30 + 
                      neighbourhood + 
                      room_type +
                      neighbourhood:cleaning_fee,
                    data = trainData, 
                    singular.ok = FALSE)
    
    predictions = exp(predict(modelTrain, testData))
    n = nrow(testData) 
    k = length(coef(modelTrain))
    RSS = sum((testData[, response] - predictions)^2)
    
    RMSE[fold] = sqrt(RSS/n)
    MedAE[fold] = median(abs(testData[, response] - predictions))
    MAE[fold] = mean(abs(testData[, response] - predictions))
    
  }
  
  meanRMSE = mean(RMSE)
  meanMedAE = mean(MedAE)
  meanMAE = mean(MAE)
  
  cat("\n\n RMSE", meanRMSE)
  cat("\n\n MedAE:", meanMedAE)
  cat("\n\n MAE:", meanMAE, "\n\n")
  
}

ModelValidationCV(airbnb, 'price', model)