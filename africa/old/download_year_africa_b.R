# devtools::install_github("https://github.com/ErikKusch/KrigR")
library(KrigR)
library(tictoc)
library(lubridate)

years <- 2023:1950
months <- 1:12

keyring_unlock("ecmwfr", password= Sys.getenv("era5_keyring"))

API_User <- as.numeric(Sys.getenv("era5_API_User"))
API_Key <- Sys.getenv("era5_API_Key")

Dir.Data <- "/media/raphael/lacie/era5land_daily_africa/"

# Africa
Extent_ext <- extent(c(-27.07,63.24,-36.67, 38.99))

# Tasks
tasks <- data.frame(
  var = c("10m_u_component_of_wind", "10m_v_component_of_wind", "2m_dewpoint_temperature", "surface_pressure", "2m_temperature", "2m_temperature", "2m_temperature", "total_precipitation"),
  stat = c("mean", "mean", "mean", "mean", "mean", "max", "min", "sum"),
  fix = c(FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, TRUE)
)

tasks <- tasks[3:4,]

# Download function
for(y in years){
  
  for(m in months){
    
    for(i in 1:nrow(tasks)){
      
      date_start <- as.character(floor_date(as.Date(paste0(y,"-",m,"-01")), "month"))
      date_end <- as.character(ceiling_date(as.Date(paste0(y,"-",m,"-01")), "month")-1)
      
      file_name <- paste0(tasks[i,1],"_",date_start,"_",date_end,"_day_",tasks[i,2])
      
      message(file_name)
      
      if(file.exists(paste0(Dir.Data, "/", file_name, ".nc"))){
        message("File already exists. Going for next.")
        next
      }
      
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
      gc()
      unlink(paste0(normalizePath(tempdir()), "/", dir(tempdir())), recursive = TRUE)
      toc()
      
    }
    
  }
  
}
