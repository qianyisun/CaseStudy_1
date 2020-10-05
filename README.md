# Team 2 - Case Study 1 README

## This Repo is organized in the following manner: 

    1. Data - This is where the Original Data as well as any CSV files created during analysis are stored
    2. ipynb and R files - Run these files in the order listed below to replicate the final product
    3. file - This folder contains the final CSV files used in 11-Application.R
    4. polygon - This folder contains the shape files used to create the maps within the shiny application
    5. uszips.csv - This CSV was downloaded from the following URL to help create the maps and provide missing county level data: https://gis-txdot.opendata.arcgis.com/datasets/texas-county-boundaries-detailed

## To use this Repo, please run the files in the following order:

    1. 01-Clean-Episodes-SNF.ipynb
    
        Description: Marina

    2. 02-get-episodes-duration.ipynb
    
       This notebook uses the episodes dataset to add a column labeled "duration", which is how long a patient stayed at a SNF. 
       Duration of stay is defined as the difference between the AdmitDate and DischargeDate columns. This column is used in 
       determining how much work is neccesary at each SNF. 

    3. 03-Calculate-Num-CC.ipynb
    
        Description: This notebook calculates the number of CCs that are required to be hired based on the number of hours that need to be worked per patient. These hours were calculated using average task times and average weekly task times. It also assumes that CCs work 52, 40-hour work weeks per year. 

    4. 04-Geocoding.ipynb
    
        Description: This notebook uses the google maps API to find the latitude and longitude of SNFs using the addresses provided. 

    5. 05-Get-Average-Duration-Per-SNF-CT.ipynb
    
        Description: Marina

    6. 06-Clean-County-Data.ipynb Quanyi

       In this notebook, we use "SNFs.xlsx" dataframe to left join "uszips.csv" dataframe to attain a dataset without missing data
       in county columns.

    7. 07-Get-Monthly-Patient-Data.ipynb 
    
       In this notebook, we load data frames from "Episodes.csv" and "Episodes_new.csv" and combine the two data frames into 
       one data frame by using left join Episodes.csv. The dataset combination reason is we need "PID","EpisodeID" columns from
       Episodes_new.csv which has the correct PIDs column after removing error records. Also, we need the format of "AdmitDate",
       "DischargeDate" columns in Episodes.csv for our further operation. Then we do a series of data manipulation to obtain 
       the dataset including Monthly-Patient-Data in 2019.
       

    8. 08-Monthly-Patients-CT.ipynb 
    
        In this notebook, we have similar data manipulation like "07-Get-Monthly-Patient-Data.ipynb". The difference is 
        we should add several contain conditions in our code to ensure that we could attain monthly different CT Patients. 
        Moreover, for some SNF which only have one type of CT, we should fill missing data with 0 as the number of patient 
        in that month.
  
    9. 09-Get-Yearly-Patient-Records.ipynb 
    
        In this notebook, we load "episodes_dur.csv" and save it as a data frame. Then we group by 'PID'and 'EpisodeID' columns 
        and use the count() function to calculate the number of patients in each snf in 2019. And in this notebook, 
        we combine nearly all relative columns into a complete data frame and convert it into a relatively complete dataset.

    10. 10-Get-County-Level-Averages.ipynb 
    
        Description: This notebook finds the number of CC, number of patients and number of SNFs on a county level using datasets 
        cleaned and prepared in notebooks 1-9. 
    
    11. 11-Application.R
    
        Description: This file generates the shiny app. The ui part is the layout of dashboard and server part helps to update map, 
        generate graphs and do calculation.
        
Note: To run the shiny app, you may need to download several packages that you might not have. To avoid the setup process for the shiny app, please visit https://team2.shinyapps.io/CaseStudy_1/. This will allow you to use the application on a web server. 
