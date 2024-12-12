base_url <- "https://www.samhsa.gov/data/system/files/media-puf-file/"

file_names <- c(
  paste0("MH-CLD-", 2013:2019, "-DS0001-bndl-data-csv_v4.zip"),
  "MH-CLD-2020-DS0001-bndl-data-csv_v3.zip",
  "MH-CLD-2021-DS0001-bndl-data-csv_v2.zip",
  "MH-CLD-2022-DS0001-bndl-data-csv_v1.zip"
)

for (file_name in file_names) {
  
  url <- paste0(base_url, file_name)
  zip_file <- paste0("source_data/", file_name)
  
  cat("Processing:", file_name, "\n")
  
  tryCatch({
    download.file(url, destfile = zip_file, quiet = TRUE, method = "auto")
    if (file.exists(zip_file)) {
      cat("Successfully downloaded:", file_name, "\n")
      
      unzip(zip_file, exdir = "source_data")
      
      unlink(zip_file)
    } else {
      cat("Download failed for:", file_name, "\n")
    }
  }, error = function(e) {
    cat("Error occurred while downloading:", file_name,
        "\nError message:", e$message, "\n")
  })
}

cat("", file = "download_sentinel")