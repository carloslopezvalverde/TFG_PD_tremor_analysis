# Cargar librerías
if (!require("readxl")) install.packages("readxl", dependencies = TRUE)
library(readxl)

# Leer archivo Excel
df <- read_excel("C:/Users/CARLOS LVS/Desktop/Prácticas INNTEGRA/Estadística/Deltas/delta post-pre.xlsx")
colnames(df) <- make.names(colnames(df))

# Variables clínicas a analizar
parametros <- c(
  "P_DTF_Delta_POST_PRE", 
  "BandPower_Delta_POST_PRE", 
  "RMS_Tremor_Delta_POST_PRE", 
  "RMS_Robust_Delta_POST_PRE", 
  "TPR_Delta_POST_PRE", 
  "Porcentaje_Temblor_Delta_POST_PRE"
)

# Función para realizar análisis por tarea
analizar_por_tarea <- function(tarea_num) {
  cat(paste0("\n🎯 ANÁLISIS TAREA ", tarea_num, ":\n"))
  cat(paste0(rep("=", 50), collapse = ""), "\n")
  
  # Filtrar datos por tarea
  datos_tarea <- df[df$Tarea == tarea_num, ]
  
  # Separar sesiones y unir por paciente
  s1 <- datos_tarea[datos_tarea$Sesion == 1, ]
  s2 <- datos_tarea[datos_tarea$Sesion == 2, ]
  
  # Verificar si hay datos suficientes
  if (nrow(s1) == 0 | nrow(s2) == 0) {
    cat("❌ No hay datos suficientes para la Tarea", tarea_num, "\n")
    return(NULL)
  }
  
  # Unir por paciente (usando Archivo_Origen como identificador de paciente)
  merged <- merge(s1, s2, by = "Archivo_Origen", suffixes = c("_S1", "_S2"))
  
  if (nrow(merged) == 0) {
    cat("❌ No se pudieron emparejar datos entre sesiones para la Tarea", tarea_num, "\n")
    return(NULL)
  }
  
  cat(paste0("📈 Pacientes emparejados: ", nrow(merged), "\n\n"))
  
  # Calcular test de Wilcoxon y estadísticas para cada parámetro
  resultados <- lapply(parametros, function(param) {
    datos1 <- merged[[paste0(param, "_S1")]]
    datos2 <- merged[[paste0(param, "_S2")]]
    
    # Eliminar valores NA
    indices_validos <- !is.na(datos1) & !is.na(datos2)
    datos1 <- datos1[indices_validos]
    datos2 <- datos2[indices_validos]
    
    if (length(datos1) >= 3 & length(datos2) >= 3) {
      test <- wilcox.test(datos1, datos2, paired = TRUE, exact = FALSE)
      
      # IQR según R (type = 7)
      iqr_r1 <- round(IQR(datos1, na.rm = TRUE, type = 7), 4)
      iqr_r2 <- round(IQR(datos2, na.rm = TRUE, type = 7), 4)
      
      # IQR según Excel (type = 6)
      iqr_excel1 <- round(quantile(datos1, 0.75, type = 6, na.rm = TRUE) - 
                            quantile(datos1, 0.25, type = 6, na.rm = TRUE), 4)
      iqr_excel2 <- round(quantile(datos2, 0.75, type = 6, na.rm = TRUE) - 
                            quantile(datos2, 0.25, type = 6, na.rm = TRUE), 4)
      
      list(
        Variable = param,
        Tarea = tarea_num,
        n_pares = length(datos1),
        V = test$statistic,
        p_value = round(test$p.value, 5),
        Mediana_S1 = round(median(datos1, na.rm = TRUE), 4),
        IQR_R_S1 = iqr_r1,
        IQR_Excel_S1 = iqr_excel1,
        Mediana_S2 = round(median(datos2, na.rm = TRUE), 4),
        IQR_R_S2 = iqr_r2,
        IQR_Excel_S2 = iqr_excel2,
        Significativo = ifelse(test$p.value < 0.05, "Sí", "No")
      )
    } else {
      list(
        Variable = param,
        Tarea = tarea_num,
        n_pares = length(datos1),
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
  
  # Mostrar resultados de la tarea
  cat("📊 Comparación entre Sesión 1 y Sesión 2:\n")
  for (res in resultados) {
    cat(paste0(
      "• ", res$Variable, " (n=", res$n_pares, ")",
      ": V = ", res$V, 
      ", p = ", res$p_value, 
      " | Med S1 = ", res$Mediana_S1, 
      " (IQR R = ", res$IQR_R_S1, ", Excel = ", res$IQR_Excel_S1, ")",
      " | Med S2 = ", res$Mediana_S2, 
      " (IQR R = ", res$IQR_R_S2, ", Excel = ", res$IQR_Excel_S2, ")",
      " | ¿Significativo? ", res$Significativo, "\n"
    ))
  }
  
  return(resultados)
}

# Ejecutar análisis para cada tarea (1-4)
cat("🔬 ANÁLISIS ESTADÍSTICO POR TAREAS")
cat("\n", paste0(rep("=", 60), collapse = ""), "\n")

# Verificar qué tareas existen en los datos
tareas_disponibles <- unique(df$Tarea)
cat("Tareas disponibles en los datos:", paste(tareas_disponibles, collapse = ", "), "\n")

# Realizar análisis para tareas 1-4
todos_resultados <- list()
for (tarea in 1:4) {
  if (tarea %in% tareas_disponibles) {
    resultados_tarea <- analizar_por_tarea(tarea)
    if (!is.null(resultados_tarea)) {
      todos_resultados[[paste0("Tarea_", tarea)]] <- resultados_tarea
    }
  } else {
    cat(paste0("\n⚠️  Tarea ", tarea, " no encontrada en los datos\n"))
  }
}

# Resumen final
cat("\n\n📋 RESUMEN GENERAL:")
cat("\n", paste0(rep("=", 40), collapse = ""), "\n")

for (tarea_nombre in names(todos_resultados)) {
  tarea_num <- gsub("Tarea_", "", tarea_nombre)
  cat(paste0("\n🎯 ", tarea_nombre, ":\n"))
  
  resultados <- todos_resultados[[tarea_nombre]]
  significativos <- sum(sapply(resultados, function(x) x$Significativo == "Sí"), na.rm = TRUE)
  total_variables <- length(resultados)
  
  cat(paste0("   Variables significativas: ", significativos, "/", total_variables, "\n"))
  
  # Mostrar variables significativas
  vars_sig <- sapply(resultados, function(x) {
    if (x$Significativo == "Sí") {
      return(paste0(x$Variable, " (p=", x$p_value, ")"))
    }
    return(NULL)
  })
  vars_sig <- vars_sig[!sapply(vars_sig, is.null)]
  
  if (length(vars_sig) > 0) {
    cat("   Variables con diferencias significativas:\n")
    for (var in vars_sig) {
      cat(paste0("   • ", var, "\n"))
    }
  }
}