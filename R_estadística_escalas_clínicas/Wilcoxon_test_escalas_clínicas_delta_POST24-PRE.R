# Cargar librerías
if (!require("readxl")) install.packages("readxl", dependencies = TRUE)
library(readxl)

# Leer archivo Excel
df <- read_excel("C:/Users/CARLOS LVS/Desktop/Prácticas INNTEGRA/Estadística/Deltas/Tremor_Scale_POST24-PRE_Deltas.xlsx")
colnames(df) <- make.names(colnames(df))

# Variables clínicas
parametros <- c(
  "TOTAL.FTM", 
  "Mejoría.global.paciente", 
  "Impresión.Cambio", 
  "Persistencia.Temblor", 
  "TOTAL.ESTIM.Sum", 
  "TOTAL.NO.ESTIM.Sum"
)

# Separar sesiones y unir por paciente
s1 <- df[df$Sesión == 1, ]
s2 <- df[df$Sesión == 2, ]
merged <- merge(s1, s2, by = "Paciente", suffixes = c("_S1", "_S2"))

# Calcular test de Wilcoxon y estadísticas
resultados <- lapply(parametros, function(param) {
  datos1 <- merged[[paste0(param, "_S1")]]
  datos2 <- merged[[paste0(param, "_S2")]]
  
  if (length(datos1) >= 3 & length(datos2) >= 3) {
    test <- wilcox.test(datos1, datos2, paired = TRUE, exact = FALSE)
    
    # IQR según R (type = 7)
    iqr_r1 <- round(IQR(datos1, na.rm = TRUE, type = 7), 2)
    iqr_r2 <- round(IQR(datos2, na.rm = TRUE, type = 7), 2)
    
    # IQR según Excel (type = 6)
    iqr_excel1 <- round(quantile(datos1, 0.75, type = 6, na.rm = TRUE) - quantile(datos1, 0.25, type = 6, na.rm = TRUE), 2)
    iqr_excel2 <- round(quantile(datos2, 0.75, type = 6, na.rm = TRUE) - quantile(datos2, 0.25, type = 6, na.rm = TRUE), 2)
    
    list(
      Variable = param,
      V = test$statistic,
      p_value = round(test$p.value, 5),
      Mediana_S1 = round(median(datos1, na.rm = TRUE), 2),
      IQR_R_S1 = iqr_r1,
      IQR_Excel_S1 = iqr_excel1,
      Mediana_S2 = round(median(datos2, na.rm = TRUE), 2),
      IQR_R_S2 = iqr_r2,
      IQR_Excel_S2 = iqr_excel2,
      Significativo = ifelse(test$p.value < 0.05, "Sí", "No")
    )
  } else {
    list(
      Variable = param,
      V = NA,
      p_value = NA,
      Mediana_S1 = NA,
      IQR_R_S1 = NA,
      IQR_Excel_S1 = NA,
      Mediana_S2 = NA,
      IQR_R_S2 = NA,
      IQR_Excel_S2 = NA,
      Significativo = "No aplica (n < 3)"
    )
  }
})

# Mostrar resultados
cat("📊 Comparación entre sesión 1 (tratamiento) y sesión 2 (placebo):\n")
for (res in resultados) {
  cat(paste0(
    "- ", res$Variable, 
    ": V = ", res$V, 
    ", p = ", res$p_value, 
    " | Mediana S1 = ", res$Mediana_S1, 
    " (IQR R = ", res$IQR_R_S1, ", IQR Excel = ", res$IQR_Excel_S1, ")",
    " | Mediana S2 = ", res$Mediana_S2, 
    " (IQR R = ", res$IQR_R_S2, ", IQR Excel = ", res$IQR_Excel_S2, ")",
    " | ¿Significativo? ", res$Significativo, "\n"
  ))
}
