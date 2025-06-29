### Estructura y Descripción del Repositorio de Códigos en R

Este repositorio contiene los códigos desarrollados en R para realizar el análisis estadístico de los parámetros extraídos de las señales inerciales (IMUs) obtenidas en las valoraciones experimentales. El objetivo principal de estos códigos es evaluar la normalidad de los datos y determinar si los cambios observados en las diferentes tareas son estadísticamente significativos tras la aplicación del tratamiento.

---

#### Contenido del Repositorio

El repositorio incluye los siguientes cuatro scripts:

1. **Saphiro\_test\_IMUs\_delta\_POST-PRE.R**

   * **Función:** Evalúa la normalidad de los datos utilizando el test de Shapiro-Wilk para los deltas calculados entre las fases POST (después de la estimulación) y PRE (antes de la estimulación).
   * **Entrada:** Deltas temporales POST-PRE para los diferentes parámetros extraídos.
   * **Salida:** Resultados del test de normalidad (estadístico W y valor p).

2. **Saphiro\_test\_IMUs\_delta\_POST24-PRE.R**

   * **Función:** Evalúa la normalidad de los datos utilizando el test de Shapiro-Wilk para los deltas calculados entre las fases POST24 (24 horas después de la estimulación) y PRE.
   * **Entrada:** Deltas temporales POST24-PRE para los diferentes parámetros extraídos.
   * **Salida:** Resultados del test de normalidad (estadístico W y valor p).

3. **Wilcoxon\_test\_IMUs\_delta\_POST-PRE.R**

   * **Función:** Aplica el test no paramétrico de Wilcoxon para comparar los cambios entre las fases POST y PRE, evaluando la significancia estadística por cada una de las cuatro tareas experimentales:

     * Reposo 1.
     * Dual Task, DT.
     * Reposo 2.
     * Arms Outstretched, AO).
   * **Entrada:** Deltas temporales POST-PRE para cada tarea.
   * **Salida:** Resultados del test de Wilcoxon (estadístico V y valor p).

4. **Wilcoxon\_test\_IMUs\_delta\_POST24-PRE.R**

   * **Función:** Aplica el test no paramétrico de Wilcoxon para comparar los cambios entre las fases POST24 y PRE, evaluando la significancia estadística por cada una de las cuatro tareas mencionadas.
   * **Entrada:** Deltas temporales POST24-PRE para cada tarea.
   * **Salida:** Resultados del test de Wilcoxon (estadístico V y valor p).

---

#### Descripción General de las Pruebas Estadísticas

1. **Shapiro-Wilk Test (Saphiro Test):**

   * Determina si los datos siguen una distribución normal. Este test es un paso previo para decidir qué tipo de prueba estadística utilizar.
   * **Interpretación:** Si el valor p < 0.05, se rechaza la hipótesis de normalidad.

2. **Wilcoxon Test:**

   * Evalúa si las diferencias observadas entre dos condiciones (POST vs PRE o POST24 vs PRE) son estadísticamente significativas.
   * **Aplicación en este proyecto:** Comparar los cambios en los parámetros medidos para cada tarea, determinando si el tratamiento tuvo un efecto significativo.
   * **Interpretación:** Si el valor p < 0.05, el cambio se considera significativo.

---

### Consideraciones Finales

* Todos los códigos han sido desarrollados y probados en R.
* Es fundamental garantizar que los archivos de entrada estén correctamente formateados y organizados para evitar errores durante la ejecución.
