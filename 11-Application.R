library(shiny)
library(leaflet)
library(leaflet.extras)
library(dplyr)
library(shinyjs) #for hide function
library(rgdal) 
library(sf)
library(ggplot2)
library(ggthemes)
library(readr)

#import dataset
#county_new <- st_read("data/County.shp")
folder="./polygon"
county_new <- st_read(dsn=folder,layer='County')
#county <- readOGR(dsn = folder, layer = "County", 
#encoding="UTF-8")
#county <- spTransform(county, CRS("+proj=longlat +ellps=GRS80"))
County_Data <- read_csv("file/CountyData.csv")

county_new <- county_new %>% 
  left_join(County_Data,by=c('CNTY_NM'='county_name')) %>% 
  mutate(`#snf` = if_else(is.na(`#snf`), 0, `#snf`)) %>% 
  mutate(patient_number_year = if_else(is.na(patient_number_year), 0, patient_number_year)) %>% 
  mutate(CC_hired = if_else(is.na(CC_hired), 0, CC_hired))


counties_simple <- rmapshaper::ms_simplify(county_new, keep = 0.05, keep_shapes = TRUE)

names(st_geometry(counties_simple)) = NULL

addresses <- read_csv("file/curr_complete_dataset_delete_columns.csv")

curr_CT1_CT2_eachmonth <- read_csv("file/curr_CT1_CT2_eachmonth.csv")

avg_duration_per_SNF_CT <- read_csv("file/avg_duration_per_SNF_CT.csv")


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

labels <- paste0(
  "<strong>County: </strong>",
  county_new$CNTY_NM,'<br/>',
  "<strong>#SNF: </strong>",
  county_new$`#snf`,'<br/>',
  "<strong>#Patients: </strong>",
  county_new$patient_number_year,'<br/>',
  "<strong>#CC: </strong>",
  county_new$CC_hired) %>% lapply(htmltools::HTML)

#layout design
ui <- bootstrapPage(
  useShinyjs(),
  tags$style(type = "text/css", "html, body {width:100%;height:100%}"),
  leafletOutput("mymap", width = "100%", height = "70%"),
  fluidRow(
    column(width=3,offset = 1,
           h2(textOutput("selected_var")),
           #h2(textInput("selected_var", NULL, value = "SNF Name", width = NULL, placeholder = NULL)),
           #uiOutput('textbox'),
           numericInput("obs", "Number of Patients:", 1, min = 1, max = 100),
    ),
    column(width=3, offset = 1,
           numericInput("p1", "%CT1:", 50, min = 0, max = 100),
           numericInput("p2", "%CT2:", 50, min = 0, max = 100),
    ),
    column(width=3,
           verbatimTextOutput("value")
    )
  ),
  #conditionalPanel("isNaN(input$mymap_shape_click)", uiOutput("controls"))
  conditionalPanel("input$mymap_shape_click", uiOutput("controls")),
  conditionalPanel("isNaN(input.mymap_marker_click)", uiOutput("controls2"))
)

server <- function(input, output, session) {
  
  #creating the first map within a function so that reset becomes easy
  
  base_map <- function(){
    leaflet(counties_simple) %>%
      addProviderTiles("Stamen.Watercolor") %>%
      #addProviderTiles(providers$CartoDB.Positron) %>% 
      addProviderTiles("Stamen.TonerHybrid") %>% 
      setView(-99.6457951,33.0624496, 5.45) %>%
      addPolygons(layerId= ~CNTY_NM,fillColor = "white", weight = 1, smoothFactor = 0.5,color = "orange",
                  opacity = 1.0, fillOpacity = 0.3,label = labels,
                  highlightOptions = highlightOptions(color = "black", weight = 3,bringToFront = TRUE))
  }
  
  # reactiveVal for the map object, and corresponding output object.
  react_map <- reactiveVal(base_map())
  output$mymap <- renderLeaflet({
    react_map()
  }) 
  
  output$controls <- renderUI({
    req(input$mymap_shape_click)
    absolutePanel(id = "controls", top = 100, left = 50, 
                  right = "auto", bottom = "auto", width = "auto", height = "auto",
                  actionButton(inputId = "reset", label = "Return to see other counties", class = "btn-primary")
    )
  })
  
  output$controls2 <- renderUI({
    req(input$mymap_marker_click)
    absolutePanel(id = "chart", class = "panel panel-default",
                  top = 35, right = 55, width = 250, fixed=TRUE,
                  draggable = TRUE, height = "auto",
                  style = "opacity: 0.7",
                  h3(textOutput("reactive_patient_count")),
                  h3(textOutput("reactive_cc_count")),
                  plotOutput("bar_chart", height="150px", width="100%"),
                  plotOutput("bar_chart2", height="160px", width="100%"))
  })
  
  # output$textbox <- renderUI({
  #   textInput("selected_var", NULL, value = "SNF Name", width = NULL, placeholder = NULL)
  # })
  
  observeEvent(input$mymap_shape_click, {
    p<- input$mymap_shape_click 
    shinyjs::show('reset')
    
    addresses_new <- addresses %>% 
      filter(addresses$county_name==p$id)
    
    leafletProxy("mymap") %>%
      clearMarkers() %>%
      clearControls() %>%
      clearTiles() %>% 
      clearShapes() %>% 
      addTiles() %>%
      setView(lng = p$lng, lat = p$lat, zoom = 8) %>% 
      #addCircles(lng = addresses_new$lng , lat = addresses_new$lat , color = 'black', 
                 #fillColor = 'grey',radius = 32186, opacity = .3) %>% 
      #addPulseMarkers(lng = addresses$long , lat = addresses$lat,icon = makePulseIcon(),layerId = addresses$ProviderName)
      addCircleMarkers(lng = addresses_new$lng , lat = addresses_new$lat,color = 'black',
                       layerId = addresses_new$PID)
  })
  
  # Making the entire map creation inside reactive function makes it easier to reset
  observeEvent(input$reset, {
    
    #hiding the control button
    shinyjs::hide('reset')
    shinyjs::hide('chart')
    
    # resetting the map
    
    react_map(base_map()) 
    
  })
  
  observeEvent(input$mymap_marker_click, { 
    m <- input$mymap_marker_click  
    name <- addresses$ProviderName[addresses$PID == m$id]
    patient_num <- addresses$patient_number_year[addresses$PID == m$id]
    cc_num <- addresses$num_CC[addresses$PID == m$id]
    output$selected_var <- renderText({name})
    updateTextInput(session,"selected_var",value=name)
    
    num_CC = round(calc_CCs(input$obs,input$p1,input$p2,m$id),4)
    output$value <- renderText({paste0("The number of CC is: \n",num_CC)})
    
    shinyjs::show('chart')
    
    output$reactive_patient_count <- renderText({
      paste0(prettyNum(patient_num, big.mark=","), " patients")
    })
    
    output$reactive_cc_count <- renderText({
      paste0(round(cc_num,4), " CC")
    })
    
    output$bar_chart <- renderPlot({
      x = c(1,2,3,4,5,6,7,8,9,10,11,12)
      y = as.vector(unlist(addresses[which(addresses$PID==m$id),3:14])) # curr_complete_dataset[i,2:13] change i to get relative row
      
      
      df <- data.frame(Month = x, Number = y)
      
      integer_breaks <- function(x)
        seq(floor(min(x)), ceiling(max(x))+1)
      
      ggplot(data=df, aes(x=Month, y=Number,group = factor(1))) +
        geom_bar(stat="identity", fill="steelblue")+
        geom_text(aes(label=Number), vjust=-0.3, size=3.5)+ scale_x_continuous(breaks=seq(1, 12, 1))+
        theme_minimal()+labs(y = "Number  of  Patients")+
        scale_y_continuous(breaks=seq(1, 1000, 3),expand = expand_scale(add=c(0,0.5)))
      
    })
    
    output$bar_chart2 <- renderPlot({
      CT1 <- curr_CT1_CT2_eachmonth[which(curr_CT1_CT2_eachmonth$PID==m$id),2:13]# curr_CT1_CT2_eachmontht[i,2:13] change i to get relative row
      CT2 <- curr_CT1_CT2_eachmonth[which(curr_CT1_CT2_eachmonth$PID==m$id),14:25] #curr_CT1_CT2_eachmonth[2,14:25] change i to get relative row
      
      X<-rep(1,24)
      count1 = 1
      count2 = 1
      for(i in 1:24){ 
        if(i%%2!=0){
          X[i]<-as.double(CT1[count1])
          count1 = count1 + 1
        } 
        else{
          X[i]<- as.double(CT2[count2])
          count2 = count2 + 1
        }
      }
      
      
      Month <- factor(rep(1:12, each = 2))
      CT_type <- rep(c('CT1','CT2'),times = 12)
      set.seed(1234)
      Number <- X
      df <- data.frame(x = Month, y = Number, CT_type = CT_type)
      ggplot(data = df, mapping = aes(x = Month, y = Number, fill = CT_type)) + 
        geom_bar(stat = 'identity', position = 'dodge')+theme_minimal() + 
        labs(y = "Number  of  Patients")+ theme(legend.title = element_blank())+
        theme(legend.position="bottom")+
        scale_y_continuous(breaks=seq(1, 1000, 3),expand = expand_scale(add=c(0,0.5)))
      
    })
    
  })

  
  
  observeEvent(input$p1,{
    newB <- 100 - input$p1
    updateNumericInput(session, "p2", value = newB)
  })
  
  observeEvent(input$p2,{
    newA <- 100 - input$p2
    updateNumericInput(session, "p1", value = newA)
  })
}
  # input part
  
  # PID = reactive({
  #   req(input$selected_var)
  #   addresses$PID[addresses$ProviderName == input$selected_var]
  # })
  # 
  # num_CC = calc_CCs(input$obs,input$p1,input$p2,PID())
  

  # num_cc = reactive({
  #   PID = addresses$PID[addresses$ProviderName == input$selected_var]
  #   num_CC = calc_CCs(input$obs,input$p1,input$p2,PID)
  #   return (round(num_CC,4))
  # })
  # 
  # output$value <- renderText({paste0("The number of CC is: \n",num_cc())})
  # 
  
  # n=reactive({
  #   return(output$selected_var)
  # })
  # output$value <- renderText({paste0("The number of CC is: \n",n())})
  

shinyApp(ui, server)
