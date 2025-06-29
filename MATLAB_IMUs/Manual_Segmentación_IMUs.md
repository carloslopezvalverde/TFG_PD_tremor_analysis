MANUAL SEGMENTACIÓN DATOS IMUs
Para segmentar los datos en tareas usamos el código segmentacion_señales_IMUs.m de MATLAB. 
Este código, tiene como objetivo procesar los datos de sensores IMU (Unidad de Medición Inercial) y de sincronización externa (trigger), para analizarlos, interpolar los tiempos y detectar los 8 eventos de interés que marcan el start y el stop de nuestras 4 tareas para así poder separarlas. 
Para que funcione, lo primero que debemos hacer en el workspace de MATLAB es llamar al archivo que queremos cortar. Para ello le damos la ruta y el nombre a la variable fileName, de esta forma:
 
Así, al ejecutar la función cut_data2, podrá seleccionar los 3 archivos .dat con el nombre dado. En este caso:
![image](https://github.com/user-attachments/assets/128fba5e-fc25-4250-bd4e-5c0ea8fbeae1)

IMPORTANTE, al dar el fileName, eliminamos el número final y el .dat, dejando el prefijo: s1_pre_p1. 

Una vez dada la ruta al fileName, el código lee los 3 archivos con ese prefijo. El archivo terminado en 1.dat corresponde a la IMU de la mano izquierda del paciente, el 2.dat a la derecha y el 3.dat se encarga de la sincronización (trigger).

A continuación, importa los datos de los sensores IMU (acelerómetro, giroscopio y magnetómetro) para las manos izquierda y derecha usando la función importfileIMU. Estos datos se almacenan en estructuras (imu_left e imu_right) que agrupan todos los canales medidos, así como las señales procesadas (signal_acc, signal_gyr, signal_mag).
![image](https://github.com/user-attachments/assets/0a767daa-aacf-4681-ae1b-4be15af3a282)


También se importan los datos del canal de sincronización desde un tercer archivo mediante la función importfileSynch_v2. Estos datos contienen una señal (EXG2CH2) que se utiliza para detectar los eventos de inicio y fin de tareas (triggers), y se almacenan en la estructura synch.

![image](https://github.com/user-attachments/assets/7c14eed3-9edf-43c0-8743-18670b5e5786)

Luego, el código realiza una interpolación temporal para cada uno de los sensores. Esto nos permite tener un vector de tiempo continuo y común para los datos, incluso si existen muestras perdidas o tiempos no uniformes. Esto se calcula eliminando los NaN, extrayendo los timestamps válidos y usando interp1 para rellenar todos los puntos.
![image](https://github.com/user-attachments/assets/1c8c0412-da80-4b0f-9ee4-399f57d365b9)

A continuación, se detectan automáticamente los puntos de inicio y fin de las tareas usando findpeaks sobre la derivada de la señal de sincronización. Los picos positivos indican los inicios de tarea y los picos negativos los finales. 
Si no se detectan exactamente cuatro inicios y cuatro finales de tarea, el código lanza un modo de corrección manual. Muestra gráficos que combinan las señales del giroscopio con la señal de sincronización, y nos solicita que introduzcamos manualmente los tiempos en los que comienzan y terminan las tareas. 
Esta situación ocurre en la gran mayoría de los casos. Para saber que puntos darle al código como inicios y finales, hay que tener en cuenta varias cosas:
•	Debemos tener 4 tareas, es decir, 8 puntos temporales (4 de inicio y 4 de final).

•	Cada tarea dura más o menos 60 segundos (si estamos en un rango entre 58-62 segundos es suficiente, ya que hay un pequeño error humano). Los tiempos entre tareas son de más o menos 15 segundos.
Sabiendo que el gráfico que nos da el código al saltar el error nos da el eje x en valores de muestras, cada segundo son 100 muestras. Lo que es lo mismo que decir que cada tarea debe rondar las 6000 muestras y los intervalos entre ellas 1500.

•	Para ver que punto exacto es cada uno, vamos añadiendo datatips en el gráfico usando shift+click izquierdo. 

•	Como el trigger no va a estar perfecto, debemos centrarnos en aquellas líneas verticales que nos den la mayor información posible. Por ejemplo
![image](https://github.com/user-attachments/assets/c9f23b74-13c3-447c-bbe1-d013518c0ad5)

En este caso vemos como hay numerosos puntos que si que somos capaces de identificar. Fijándonos en estos, vamos tratando de hacer el cálculo de 6000 y 1500 para identificar las 4 tareas.


•	Si en algún caso, las 3 primeras tareas salen bien (cercanas a 60 segundos) pero la 4ª no está completa, NO movemos las 3 primeras para que la 4ª salga entera. Indicamos que la 4ª tarea termina en la última muestra de la grabación aunque esta tarea sea jucho más corta que las demás.

•	Si hay algún error de que no hay muestras suficientes, por errores en la grabación o que simplemente no hay trigger lo anotamos y NO las cortamos erróneamente.

Para indicar los 8 puntos temporales al código, esperamos a que nos pregunte y contestamos de la siguiente forma:
[1000 7000 8500 14500 16000 22000 23500 29500]
(esto es un caso imaginario, nunca quedarán los valores temporales tan exactos)

Dados los valores (en muestras), se calculan las duraciones de cada tarea a partir de los marcadores de inicio y fin, y se muestran en segundos

Las duraciones se derivan de los datos del IMU derecho, asumiendo que todos los sensores están sincronizados. El código también define los nombres de las tareas correspondientes (por ejemplo, “Resting Task” o “Dual Task”) y corta las señales según cada tarea. 
Por último, guarda los datos actualizados creando un nuevo archivo .mat con el nombre del fileName y _all_updated.mat

![image](https://github.com/user-attachments/assets/f7269113-9af1-4477-9733-97f4bba31bed)
