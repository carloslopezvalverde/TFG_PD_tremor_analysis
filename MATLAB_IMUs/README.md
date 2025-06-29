### Estructura y Descripción del Repositorio de Códigos MATLAB - IMUs

El repositorio contiene los códigos desarrollados para el Trabajo de Fin de Grado titulado *Evaluación de la Estimulación Eléctrica Periférica Sensorial para la Reducción del Temblor en Pacientes con Enfermedad de Parkinson*. Su principal objetivo es procesar y analizar las señales inerciales obtenidas mediante sensores IMU durante las valoraciones experimentales (reposo, tareas motoras y estimulación). A continuación, se describe la funcionalidad de los principales scripts y funciones en orden de uso recomendado.

---

#### 1. Segmentación de Señales (*segmentacion\_señales\_IMUs.m*)

Este script debe ejecutarse primero una vez recogidas las señales inerciales durante las valoraciones experimentales. Sus principales funcionalidades son:

* Fusionar los tres archivos *.dat* correspondientes a cada repetición (IMU derecha, IMU izquierda y trigger).
* Segmentar automáticamente las señales en cuatro tareas experimentales:

  1. Reposo 1.
  2. DT - Dual Task.
  3. Reposo 2.
  4. AO - Arms Outstrechted

El script genera como salida un archivo *.mat* que contiene las señales sincronizadas y segmentadas por tarea.

**Dependencias:**

* *importfileIMU.m*
* *importfileSynch\_v2.m*

Para garantizar su correcto uso, consulte el documento "README\_Manual\_Segmentación\_IMUs.md", donde se detalla el procedimiento paso a paso.

---

#### 2. Extracción de Parámetros de IMU (*extraccion\_parametros\_IMUs.m*)

Este script realiza el análisis cuantitativo de las señales segmentadas para calcular métricas clave que caracterizan el temblor:

1. DTF	- Frecuencia Dominante del Temblor (Dominant Tremor Frequency)
2. P_DTF -	Potencia en la Frecuencia Dominante del Temblor (Power at the Dominant Tremor Frequency)
3. Band Power -	Potencia en la Banda
4. RMS - Valor Cuadrático Medio (Root Mean Square)
5. RMS Robust- Valor Cuadrático Medio Robusto (Robust Root Mean Square)
6. %Tremor -	Porcentaje de Tiempo con Temblor
7. TPR	- Relación de Potencia del Temblor (Tremor Power Ratio)


Además genera gráficas representativas para la realización de los cálculos:

  * Espectros de potencia (*Power Spectral Density*, PSD).
  * Espectrogramas.

Los resultados pueden extraerse manualmente o mediante un script adicional automatizado.

---

#### Determinación de Umbral de Temblor (*determinacion\_umbral\_%tremor.m*)

SCRIPT COMPLEMENTARIO

Este script se usó para determinar el umbral a partir del cual en un espectrograma se define como actividad temblorosa y así determinar los intervalos de temblor en cada repetición y calcular %Tremor.

**Procedimiento:**

1. Utiliza los archivos generados tras la segmentación.
2. Aplica un algoritmo basado en la potencia de banda del temblor.
3. Determina los intervalos temporales donde se supera un umbral predefinido.

---

#### 4. Visualización de Métricas en Radar Plots (*radar\_plots\_parámetros\_IMUs.m*)

Este script genera visualizaciones tipo *radar plot* para representar de manera compacta y visual los valores de las seis métricas relacionadas con el temblor (todas excepto DTF ; mencionadas previamente) por tarea y sesión.

**Salidas generadas:**

* 1 figura con ocho *radar plots* por sujeto:

  1. Cuatro tareas: Reposo 1, DT, Reposo 2, AO.
  2. Dos condiciones: SATS (estimulación real) y SHAM (placebo).

**Aplicación:** Estas gráficas facilitan la comparación de la evolución de los parámetros entre sesiones y tareas, y forman parte de los resultados incluidos en el TFG.

---

### Consideraciones Finales

Todos los códigos han sido desarrollados y probados en MATLAB. Se recomienda revisar los comentarios en los scripts para un uso eficiente y para garantizar la reproducibilidad de los resultados.
