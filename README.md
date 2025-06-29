### Estructura del Repositorio Global para el TFG

Este repositorio contiene algunos de los recursos desarrollados para el Trabajo de Fin de Grado titulado *Evaluación de la Estimulación Eléctrica Periférica Sensorial para la Reducción del Temblor en Pacientes con Enfermedad de Parkinson*. La estructura se divide en tres carpetas principales que incluyen los códigos y análisis utilizados en las diferentes etapas del proyecto.

---

#### 1. Códigos MATLAB para IMUs

Esta carpeta contiene los scripts desarrollados en MATLAB para el procesamiento y análisis de las señales inerciales (*IMUs*) obtenidas durante las valoraciones experimentales. Los códigos se enfocan en:

* Segmentar las señales por tareas experimentales.
* Extraer parámetros cuantitativos relacionados con el temblor.
* Generar visualizaciones gráficas (e.g., radar plots) para la interpretación de resultados.
* Cálculo del valor del Minimum Detectable Change (MDC)

**Propósito:** Facilitar el procesamiento de los datos de las IMUs y preparar las métricas necesarias para el análisis estadístico, además de evaluar la eficacia del tratamiento SATS.

---

#### 2. Códigos en R para Estadística de IMUs

Esta carpeta incluye los scripts en R utilizados para realizar el análisis estadístico de los parámetros extraídos de las señales inerciales. Los análisis se enfocan en:

* Evaluar la normalidad de los datos mediante el test de Shapiro-Wilk.
* Determinar la significancia estadística de los cambios observados entre las fases PRE, POST y POST24 utilizando el test no paramétrico de Wilcoxon.

**Propósito:** Validar los resultados obtenidos del procesamiento de señales y determinar si los efectos del tratamiento son estadísticamente significativos.

---

#### 3. Códigos en R para Estadística de Escalas Clínicas

Esta carpeta contiene los scripts en R dedicados al análisis estadístico de las puntuaciones obtenidas en las escalas clínicas utilizadas durante el estudio experimental. Los análisis incluyen:

* Comparaciones estadísticas de las puntuaciones entre las fases PRE, POST y POST24 mediante el test de Wilcoxon.

**Propósito:** Evaluar si los cambios observados en las escalas clínicas son consistentes con los resultados obtenidos de las señales inerciales y confirmar la efectividad del tratamiento.

---

### Propósito General

Este repositorio está diseñado para centralizar todos los recursos del proyecto, facilitar la reproducibilidad de lo que se ha realizado y atender cualquier curiosidad que pueda surgir al tribunal o a otras personas interesadas en los procedimientos.

---

### Consideraciones

* **Organización:** Asegúrate de seguir la estructura de carpetas y las instrucciones incluidas en cada README específico.
* **Requerimientos:** Los scripts en MATLAB han sido probados en la versión R2021b, y los códigos en R en la versión 4.2.2.
  

