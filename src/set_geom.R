library(sf)
library(dplyr)
library(stringr)
library(stringi)

# Importa la tabla de datos de los nombres de municipios y la cantidad de votos.
# Pasa el nombre de los municipios a minúscula y cambia el nombre de la columna
# con el fin de relacionar la tabla con la tabla de municipios de INEGI.
votos <- read.csv("./data/total_de_votos_por_municipio.csv")
votos$nombre_municipio <- votos$nombre_municipio |> tolower()
colnames(votos) <- c("NOMGEO", "VOTOS")

# Importa la tabla de datos de municipios con sus geometrías y filtra para el 
# estado de Sonora
muni_mexico <- st_read("./data/mun22gw/mun22gw.shp")

muni_sonora <- muni_mexico |>
  filter(NOM_ENT == "Sonora") |>
  select(CVEGEO, CVE_ENT, CVE_MUN, NOMGEO, NOM_ENT)

# Quita el acento de los nombres de los municipios y los pasa a minúsculas para 
# que estén igual que la tabla de votos. Haz la unión entre las dos tablas para 
# tener la tabla correcta para hacer el mapa.
votos_sf <- muni_sonora |>
  mutate(NOMGEO = stri_trans_general(str = NOMGEO, id = "Latin-ASCII") |>
           tolower()) |>
  left_join(votos)

votos_sf <- votos_sf |>
  mutate(NOMGEO = case_when(CVE_MUN == muni_sonora$CVE_MUN ~ NOMGEO))

dir.create("resultados")

votos_sf |>
  st_write(dsn = "./resultados/votos_sf.geojson",
           driver = "GeoJSON",
           delete_layer = TRUE)

# Haz una primera versión del mapa
votos_sf |>
  select(VOTOS, geometry) |>
  plot()
