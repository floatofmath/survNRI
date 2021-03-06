get.estimates <- function( time, event, model1, model2, data,  predict.time, method ="all",  bw.power = 0.35
) {



#using markers y1 and y2

#first calculate conditional probability P(T<t|Y) for each individual at predict.time = t based on a Cox model using 'PtfromCox'


#model 2
  model2.data <- as.data.frame(cbind(time = time, event = event, data[,model2]))
  Pt2 <- PtfromCox(model2.data, predict.time)

#marker 1
  model1.data <- as.data.frame(cbind(time = time, event = event, data[,model1]))
  Pt1 <- PtfromCox(model1.data, predict.time)


  result <- as.data.frame(matrix(nrow = length(method), ncol = 3))
  names(result) = c("NRI.event", "NRI.nonevent", "NRI")
  rownames(result) = method 
  
  
 
  if(is.element("IPW", method)){
    result["IPW", ]  <- NRI.smooth.IPW(times = time, status = event, predict.time = predict.time, Pt2 = Pt2, Pt1 = Pt1, yes.smooth=FALSE, bw.power = bw.power)
  }  
  
  if(is.element("KM", method)){
    result["KM", ] <- NRI.KM(Pt2 = Pt2, Pt1 = Pt1, data = cbind(time, event), predict.time = predict.time)
  }  

if(is.element("SEM", method)){
    SEM <- NRI.SEM(Pt2 = Pt2,Pt1 = Pt1)
    result["SEM", ] <- SEM
  }  

if(is.element("SmoothIPW", method)){
    SmoothIPW <- NRI.smooth.IPW(times = time, status = event, predict.time = predict.time, Pt2 = Pt2, Pt1 = Pt1, yes.smooth=TRUE, bw.power = bw.power)
    result["SmoothIPW", ]  <- SmoothIPW

  } 
 
if(is.element("Combined", method)){

      pvalue.test <- coxph(as.formula(paste("Surv(time, event)~", paste(model2, collapse = "+"))), data =model2.data)
      pvalue.test <- cox.zph(pvalue.test)$table
      pvalue.test <- pvalue.test[length(pvalue.test)]

     

      if(!is.element("SmoothIPW", method)) SmoothIPW <-  NRI.smooth.IPW(times = time, status = event, predict.time = predict.time, Pt2 = Pt2, Pt1 = Pt1, bw.power = bw.power, yes.smooth=TRUE)
      if(!is.element("SEM", method)) SEM <- NRI.SEM(Pt2 = Pt2,Pt1 = Pt1)

      result["Combined", ] <- SmoothIPW*(1-pvalue.test)+pvalue.test*SEM
  }  

  return(result)

} 
