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
    
        Description: Drew

    3. 03-Calculate-Num-CC.ipynb
    
        Description: Umang

    4. 04-Geocoding.ipynb
    
        Description: Umang

    5. 05-Get-Average-Duration-Per-SNF-CT.ipynb
    
        Description: Marina

    6. 06-Clean-County-Data.ipynb Quanyi

        Description: Quanyi

    7. 07-Get-Monthly-Patient-Data.ipynb 
    
        Description: Quanyi

    8. 08-Monthly-Patients-CT.ipynb 
    
        Description: Quanyi
  
    9. 09-Get-Yearly-Patient-Records.ipynb 
    
        Description: Quanyi

    10. 10-Get-County-Level-Averages.ipynb 
    
        Description: Umang
    
    11. 11-Application.R
    
        Description: Yilin
        
Note: To run the shiny app, you may need to download several packages that you might not have. To avoid the setup process for the shiny app, please visit https://team2.shinyapps.io/CaseStudy_1/. This will allow you to use the application on a web server. 
