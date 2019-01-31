library(dplyr) # data manipulation and pipe operator (%>%)
library(tidyr)
library(gtools) # mixedsort
library(plotly)
library(ggplot2)

n_us = 10 # initial value for the value box

csv_station_locations <- read.csv(file = 'data/external/emplacement-des-gares-idf.csv',
                                  sep = ";",
                                  header = TRUE)

csv_colors = read.csv(file = 'data/colors.csv',
                      sep = ";",
                      header = TRUE)

csv_valid_day <- read.csv(file = 'data/external/validations-sur-le-reseau-ferre-nombre-de-validations-par-jour-1er-sem.csv',
                          sep = ";",
                          header = TRUE)

csv_valid_day_hour <- read.csv(file = 'data/external/validations-sur-le-reseau-ferre-profils-horaires-par-jour-type-1er-sem.csv',
                               sep = ";",
                               header = TRUE)

#head(csv_station_locations)
#tail(csv_station_locations)
#summary(csv_station_locations)
#dplyr::tbl_df(csv_station_locations)
#dplyr::glimpse(csv_station_locations)
#View(csv_station_locations)

#dplyr::rename(csv_station_locations, replace = c("Geo Point" = "GeoPoint"))
#df2 <- dplyr::select(csv_station_locations, Geo_Point = Geo.Point)
#head(df2, 4)

df_station_locations <- csv_station_locations %>%
  dplyr::select(Geo.Point, GARES_ID, NOMLONG, RES_COM, INDICE_LIG, RESEAU) %>% # select useful data
  dplyr::rename(LOCATION = Geo.Point) %>% # rename columns
  tidyr::separate(LOCATION, c("LAT", "LNG"), ",") %>% # split coordinates into columns
  dplyr::mutate(LAT = as.numeric(LAT), LNG = as.numeric(LNG)) %>% # convert types
  merge(csv_colors, by = "RES_COM") # add color column

#unique_RES_COM = csv_station_locations %>% distinct(RES_COM)
#vect_unique_RES_COM = unique_RES_COM$RES_COM # transform as vector
#vect_unique_RES_COM = unique_RES_COM %>% pull() # other way to do it
# vect_unique_RES_COM_sorted = unique_RES_COM %>%
#   dplyr::arrange(RES_COM) %>% # sort by RES_COM
#   pull() # transform as vector

unique_RES_COM = csv_station_locations %>%
  distinct(RES_COM) %>% # get all RES_COM values
  #dplyr::arrange(RES_COM) %>% # sort by RES_COM
  pull() %>% # transform as vector
  as.character() %>%
  gtools::mixedsort() # not lexicographic sorting M1 M10 M2, instead : M1 M2 M10

#x = c('M10', 'M1', 'M2', 'M20')
#sort(x)
#gtools::mixedsort(x)

unique_RESEAU = csv_station_locations %>%
  distinct(RESEAU) %>% # get all RESEAU values
  pull() %>% # transform as vector
  as.character() %>%
  gtools::mixedsort()

unique_NOMLONG = csv_station_locations %>%
  distinct(NOMLONG) %>% # get all NOMLONG values
  pull() %>% # transform as vector
  as.character() %>%
  gtools::mixedsort()

df_valid_day <- csv_valid_day %>%
  dplyr::select(JOUR, LIBELLE_ARRET, NB_VALD) %>% # select useful data
  dplyr::rename(NOMLONG = LIBELLE_ARRET) %>% # rename columns
  dplyr::mutate(NB_VALD = as.character(NB_VALD)) %>% # convert types
  #dplyr::mutate(NB_VALD = replace(NB_VALD, NB_VALD == "Moins de 5", "0"))
  dplyr::mutate(NB_VALD = suppressWarnings(as.numeric(NB_VALD))) %>% # volontary coerce NA values for non numeric values
  tidyr::drop_na(NB_VALD) %>%
  #dplyr::mutate(NB_VALD = tidyr::replace_na(NB_VALD, 0))
  #dplyr::mutate(JOUR = as.POSIXct(JOUR, format="%Y-%m-%d"))
  dplyr::mutate(JOUR = as.Date(JOUR, format="%Y-%m-%d"))

df_sum_valid_day_station <- df_valid_day %>%
  group_by(JOUR, NOMLONG) %>%
  summarize(NB_VALD = sum(NB_VALD))

df_max_valid_day_station <- df_valid_day %>%
  group_by(JOUR, NOMLONG) %>%
  summarize(NB_VALD = max(NB_VALD))

# df_sum_valid_day_AUBER = df_sum_valid_day_station %>%
#   dplyr::filter(NOMLONG == 'AUBER')

#hist(df_sum_valid_day_AUBER$NB_VALD)

# pp <- plot_ly(
#   x = df_sum_valid_day_AUBER$JOUR,
#   y = df_sum_valid_day_AUBER$NB_VALD,
#   name = "Valid station",
#   type = "bar"
# )
# pp

df_sum_valid_sem_station <- df_valid_day %>%
  group_by(NOMLONG) %>%
  summarize(NB_VALD = sum(NB_VALD))

# this function re-map a number from one range to another
# entry range : [a, b]
# exit range : [d, d]
# x the value to map
map <- function(x, a, b, c, d) {
  return(c+((d-c)/(b-a))*(x-a))
}

df_sum_valid_sem_station_norm <- df_valid_day %>%
  group_by(NOMLONG) %>%
  summarize(NB_VALD = sum(NB_VALD)) %>%
  mutate(NORM = map(NB_VALD, min(NB_VALD), max(NB_VALD), 3, 15))

#normalized = (x-min(x))/(max(x)-min(x))


df_sum_valid_sem_station_norm_locations <- df_station_locations %>%
  merge(df_sum_valid_sem_station_norm, by = "NOMLONG", all.x = TRUE) %>% # left join for unexisting data in y when merge(x, y)
  dplyr::mutate(NORM = tidyr::replace_na(NORM, 3))

#hist(df_sum_valid_sem_station_norm$NB_VALD)
#hist(df_sum_valid_sem_station_norm$NORM)


# dff <- csv_valid_day %>%
#   group_by(JOUR, LIBELLE_ARRET)

df_sum_valid_day_station_norm <- df_valid_day %>%
  group_by(JOUR, NOMLONG) %>%
  summarize(NB_VALD = sum(NB_VALD)) %>%
  mutate(NORM = map(NB_VALD, min(NB_VALD), max(NB_VALD), 3, 15))

df_sum_valid_day_station_norm_locations <- df_station_locations %>%
  merge(df_sum_valid_day_station_norm, by = "NOMLONG", all.x = TRUE) %>%
  dplyr::mutate(NORM = tidyr::replace_na(NORM, 3))


unique_JOUR = df_valid_day %>%
  distinct(JOUR) %>%
  dplyr::arrange(JOUR) %>%
  pull() #%>% # transform as vector
  #as.character()

#sapply(df_sum_valid_day_station_norm_locations, class)

df_leaflet <- df_sum_valid_day_station_norm_locations %>%
  #dplyr::filter(JOUR== as.character(input$year))
  dplyr::filter(JOUR== min(unique_JOUR))
