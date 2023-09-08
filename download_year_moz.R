# devtools::install_github("https://github.com/ErikKusch/KrigR")
library(KrigR)
library(tictoc)
library(lubridate)

years <- 2022:2000
months <- 1:12

keyring_unlock("ecmwfr", password= Sys.getenv("era5_keyring"))

API_User <- as.numeric(Sys.getenv("era5_API_User"))
API_Key <- Sys.getenv("era5_API_Key")

Dir.Data <- "era5_data_moz"

# Mozambique
Extent_ext <- extent(c(30.080566,40.979004,-27.469287,-10.314919))

# Tasks
tasks <- data.frame(
  var = c("10m_u_component_of_wind", "10m_v_component_of_wind", "2m_temperature", "2m_temperature", "2m_temperature", "total_precipitation"),
  stat = c("mean", "mean", "mean", "max", "min", "sum"),
  fix = c(FALSE, FALSE, FALSE, FALSE, FALSE, TRUE)
)

# Download function
for(i in 1:nrow(tasks)){
  
  for(y in years){
    
    for(m in months){
      
      date_start <- as.character(floor_date(as.Date(paste0(y,"-",m,"-01")), "month"))
      date_end <- as.character(ceiling_date(as.Date(paste0(y,"-",m,"-01")), "month")-1)
      
      file_name <- paste0(tasks[i,1],"_",date_start,"_",date_end,"_day_",tasks[i,2])
      
      message(file_name)
      
      tic()
      QS_Raw <- download_ERA(
        Variable = tasks[i,1],
        PrecipFix = tasks[i,3],
        DataSet = "era5-land",
        DateStart = date_start,
        DateStop = date_end,
        TResolution = "day",
        TStep = 1,
        FUN = tasks[i,2],
        Extent = Extent_ext,
        Dir = Dir.Data,
        FileName = file_name,
        Cores = 1,
        API_User = API_User,
        API_Key = API_Key,
        TryDown = 100
      )
      rm(QS_Raw)
      toc()
      
    }
    
  }
  
}
