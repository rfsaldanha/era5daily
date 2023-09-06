# devtools::install_github("https://github.com/ErikKusch/KrigR")
library(KrigR)
library(beepr)
library(tictoc)

year <- 2022

API_User <- as.numeric(Sys.getenv("era5_API_User"))
API_Key <- Sys.getenv("era5_API_Key")

Dir.Data <- "era5_data"

# Latin America
Extent_ext <- extent(c(-118.47,-34.1,-56.65, 33.28))

# Tasks
tasks <- data.frame(
  var = c("10m_u_component_of_wind", "10m_v_component_of_wind", "2m_temperature", "2m_temperature", "2m_temperature", "total_precipitation"),
  stat = c("mean", "mean", "mean", "max", "min", "sum"),
  fix = c(FALSE, FALSE, FALSE, FALSE, FALSE, TRUE)
)

# Download function
for(i in 1:nrow(tasks)){
  message(paste0(tasks[i,1], " - ", tasks[i,2]))
  
  tic()
  QS_Raw <- download_ERA(
    Variable = tasks[i,1],
    PrecipFix = tasks[i,3],
    DataSet = "era5-land",
    DateStart = paste0(year,"-01-01"),
    DateStop = paste0(year,"-12-31"),
    TResolution = "day",
    TStep = 1,
    FUN = tasks[i,2],
    Extent = Extent_ext,
    Dir = Dir.Data,
    Cores = 8,
    API_User = API_User,
    API_Key = API_Key,
    TryDown = 100
  )
  toc()
  
  beepr::beep(sound = 2)
}
