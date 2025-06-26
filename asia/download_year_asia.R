# Packages
# devtools::install_github("https://github.com/ErikKusch/KrigR")
library(KrigR)
library(sf)
library(tictoc)
library(lubridate)
library(cli)

# Settings
years <- 1950:2024
months <- 1:12

# Copernicus Data Store API access
# keyring_unlock("ecmwfr", password= Sys.getenv("era5_keyring"))
API_User <- Sys.getenv("era5_API_User")
API_Key <- Sys.getenv("era5_API_Key")

# Destination folder
Dir.Data <- "/media/raphaelsaldanha/lacie/era5land_daily_asia/"

# Asia bbox
Extent_ext <- terra::ext(c(60.5, 180.0, -48.7, 54.9))

# Tasks
tasks <- data.frame(
  var = c(
    "10m_u_component_of_wind",
    "10m_v_component_of_wind",
    "2m_dewpoint_temperature",
    "surface_pressure",
    "2m_temperature",
    "2m_temperature",
    "2m_temperature",
    "total_precipitation"
  ),
  stat = c("mean", "mean", "mean", "mean", "mean", "max", "min", "sum"),
  fix = c(FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, TRUE)
)

# Download routine
for (i in 1:nrow(tasks)) {
  for (y in years) {
    for (m in months) {
      # Date interval
      date_start <- as.character(floor_date(
        as.Date(paste0(y, "-", m, "-01")),
        "month"
      ))
      date_end <- as.character(
        ceiling_date(as.Date(paste0(y, "-", m, "-01")), "month") - 1
      )

      # File name
      file_name <- paste0(
        tasks[i, 1],
        "_",
        date_start,
        "_",
        date_end,
        "_day_",
        tasks[i, 2]
      )

      cli_h1(file_name)

      if (file.exists(paste0(Dir.Data, "/", file_name, ".nc"))) {
        cli_alert_warning("File already exists. Going for next.")
        next
      }

      cli_alert_info("Starting download...")
      tic()
      QS_Raw <- CDownloadS(
        Variable = tasks[i, 1],
        CumulVar = tasks[i, 3],
        DataSet = "reanalysis-era5-land",
        DateStart = date_start,
        DateStop = date_end,
        TResolution = "day",
        TStep = 1,
        FUN = tasks[i, 2],
        Extent = Extent_ext,
        Dir = Dir.Data,
        FileName = file_name,
        Cores = 1,
        API_User = API_User,
        API_Key = API_Key,
        TryDown = 100
      )
      rm(QS_Raw)
      unlink(
        paste0(normalizePath(tempdir()), "/", dir(tempdir())),
        recursive = TRUE
      )
      toc()
      cli_alert_success("Done! Going for next...")
    }
  }
}
