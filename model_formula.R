library(tidyverse)


avg_duration_per_SNF_CT <- read_csv("D:/fall2020/case study/case study 1/avg_duration_per_SNF_CT.csv")


calc_CCs <- function (pat_num, CT1_prop, CT2_prop, PID, df = avg_duration_per_SNF_CT){
  if (pat_num < 0){
    return("Negative value is not acceptable. Please enter a valid number.")
  } 
  if ((CT1_prop*0.01 > 1|CT1_prop*0.01 < 0)|(CT2_prop*0.01 > 1|CT2_prop*0.01 < 0)){
    return("Proportion ranges from (0,100). Please enter a valid number.")
  }
  
  
  avg_CT1_time = as.numeric(df[df$PID == PID & df$ContractType == "CT1", "average_time_spent"])
  avg_CT2_time = as.numeric(df[df$PID == PID & df$ContractType == "CT2", "average_time_spent"])
  

  CCs_num = (((pat_num*(CT1_prop*0.01)*avg_CT1_time)/60)/52)/40 + (((pat_num*(CT2_prop*0.01)*avg_CT2_time)/60)/52)/40
 
  return(CCs_num)
    
}

