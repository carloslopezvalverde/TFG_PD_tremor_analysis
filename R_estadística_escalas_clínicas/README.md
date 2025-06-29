### Estructura y Descripción del Repositorio de Códigos en R

Este repositorio contiene los códigos desarrollados en R para realizar el análisis estadístico de los cambios en las escalas clínicas utilizadas en el estudio experimental. El objetivo principal de estos códigos es determinar si los cambios observados en los deltas calculados (POST-PRE y POST24-PRE) son estadísticamente significativos tras la aplicación del tratamiento.

---

#### Contenido del Repositorio

El repositorio incluye los siguientes dos scripts:

1. **Wilcoxon\_test\_escalas\_clínicas\_delta\_POST-PRE.R**

   * **Función:** Aplica el test no paramétrico de Wilcoxon para comparar los cambios entre las fases POST (después de la estimulación) y PRE (antes de la estimulación) en las escalas clínicas. Este análisis permite determinar si los cambios observados son significativos.
   * **Entrada:** Deltas temporales POST-PRE para las diferentes escalas clínicas evaluadas.
   * **Salida:** Resultados del test de Wilcoxon (estadístico V y valor p).

2. **Wilcoxon\_test\_escalas\_clínicas\_delta\_POST24-PRE.R**

   * **Función:** Aplica el test no paramétrico de Wilcoxon para comparar los cambios entre las fases POST24 (24 horas después de la estimulación) y PRE en las escalas clínicas. Este análisis permite evaluar si los efectos del tratamiento se mantienen a las 24 horas.
   * **Entrada:** Deltas temporales POST24-PRE para las diferentes escalas clínicas evaluadas.
   * **Salida:** Resultados del test de Wilcoxon (estadístico V y valor p).

---

#### Descripción General de las Pruebas Estadísticas

1. **Wilcoxon Test:**

   * Evalúa si las diferencias observadas entre dos condiciones (POST vs PRE o POST24 vs PRE) son estadísticamente significativas.
   * **Aplicación en este proyecto:** Comparar los cambios en las puntuaciones de las escalas clínicas para determinar si el tratamiento tuvo un efecto significativo.
   * **Interpretación:** Si el valor p < 0.05, el cambio se considera significativo.

---

### Consideraciones Finales

* Todos los códigos han sido desarrollados y probados en R.
* Es fundamental garantizar que los archivos de entrada estén correctamente formateados y organizados para evitar errores durante la ejecución.
