# Instala y carga el paquete necesario
if (!require("readxl")) install.packages("readxl", dependencies = TRUE)
library(readxl)

# Lee el archivo Excel (ajusta el nombre y la ruta si es necesario)
df_post24_pre <- read_excel("C:/Users/CARLOS LVS/Desktop/Deltas/delta post24-pre.xlsx")

# Convierte todo a numérico por seguridad
df_post24_pre <- as.data.frame(lapply(df_post24_pre, function(col) {
  suppressWarnings(as.numeric(as.character(col)))
}))

# Aplica el test de Shapiro-Wilk a cada columna
resultados_post24_pre <- lapply(names(df_post24_pre), function(col_name) {
  col_data <- df_post24_pre[[col_name]]
  col_data <- col_data[!is.na(col_data)]  # Elimina NAs
  
  if (length(col_data) >= 3 && length(col_data) <= 5000) {
    test <- shapiro.test(col_data)
    list(
      variable = col_name,
      W = round(test$statistic, 5),
      p_value = round(test$p.value, 5),
      normalidad = ifelse(test$p.value > 0.05, "Sí", "No")
    )
  } else {
    list(
      variable = col_name,
      W = NA,
      p_value = NA,
      normalidad = "No aplica (n < 3)"
    )
  }
})

# Muestra los resultados en consola
cat("Resultados del test de Shapiro-Wilk (POST24 - PRE):\n")
for (res in resultados_post24_pre) {
  cat(paste0(
    "- ", res$variable, 
    ": W = ", res$W, 
    ", p-value = ", res$p_value, 
    ", ¿Distribución normal? ", res$normalidad, "\n"
  ))
}
