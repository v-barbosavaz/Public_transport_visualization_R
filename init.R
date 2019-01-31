# PACKAGES INSTALLATION 

# First way to manage installation
# default : It can be slow when thousands of packages are installed - doc of installed.packages
# packages_list <- c("dplyr", "tidyr", "gtools")
# new_packages <- packages_list[!(packages_list %in% installed.packages()[,"Package"])]
# if(length(new_packages) > 0){install.packages(new_packages)}
# lapply(packages_list, require, character.only=T) # (extra) load ackages

# Second way to manage installation
# default : it uses a non official library
# if(!require("pacman")) install.packages("pacman")
# pacman::p_load(package1, package2, package_n)

# Third way to manage installation
# default : it can stop the program if update available
# install.packages(c("shiny", "dplyr"))

# Fourth way to manage installation
# Require return a boolean whereas library return an error
# if the package is not installed.
# Maybe a better approach and faster than installed.packages
# if(!require(shiny)) install.packages('shiny')
# library('shiny')

# Fifth way to manage installation ?
# I have seen a project using a simple .txt file with all
# the packages needed and their version too !
# I will look at this in detail in the future.

# THE WINNING WAY to install packages
# install_packages function: install (and load) multiple R packages easily
# check if packages are installed. Install them if they are not (then load them into the R session)
install_packages <- function(pkgs){
  new_pkgs <- pkgs[!(pkgs %in% installed.packages()[, "Package"])]
  if (length(new_pkgs) >0){install.packages(new_pkgs, dependencies = TRUE)}
  #sapply(pkgs, require, character.only = TRUE)
}
packages_list <- c("dplyr", "tidyr", "gtools", "plotly", "ggplot2", "shiny", "shinydashboard", "leaflet", "wordcloud", "DT")
install_packages(packages_list)

#open -a TextEdit .gitignore

# download the datasets from WEB
datasets <- c('emplacement-des-gares-idf.csv',
              'validations-sur-le-reseau-ferre-nombre-de-validations-par-jour-1er-sem.csv',
              'validations-sur-le-reseau-ferre-profils-horaires-par-jour-type-1er-sem.csv')

for(file in datasets){
  if(!file.exists(file.path('data/external', file))){
    URL <- file.path('https://perso.esiee.fr/~barbosav/DRIO-4103C/DATA', file)
    folder <- "data/external"
    filename <- basename(URL)
    download.file(URL, destfile=file.path(folder, filename)) # method="libcurl"
  }
}