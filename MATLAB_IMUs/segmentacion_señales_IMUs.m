% processIMUData processes IMU and synchronization data for a given file name base.

% Input:

%   fileName - Base name of the files to process (e.g., 'TestData')

 

% Definir los nombres de los archivos

dataFile2 = strcat(fileName, '1.dat');

dataFile1 = strcat(fileName, '2.dat')   ;

dataFile3 = strcat(fileName, '3.dat');

 

% Importar datos de los sensores IMU

[TimeStamp1, TimeStampUnix1, LowNoiseAccelerometerX1, LowNoiseAccelerometerY1, LowNoiseAccelerometerZ1, ...
    GyroscopeX1, GyroscopeY1, GyroscopeZ1, MagnetometerX1, MagnetometerY1, MagnetometerZ1, signal_acc1, signal_gyr1, signal_mag1] = importfileIMU(dataFile1);

 

% imu_right

 

imu_right = struct('TimeStamp', TimeStamp1, 'TimeStampUnix', TimeStampUnix1, ...
    'LowNoiseAccelerometerX', LowNoiseAccelerometerX1, 'LowNoiseAccelerometerY', LowNoiseAccelerometerY1, 'LowNoiseAccelerometerZ', LowNoiseAccelerometerZ1, ...
    'GyroscopeX', GyroscopeX1, 'GyroscopeY', GyroscopeY1, 'GyroscopeZ', GyroscopeZ1, ...
    'MagnetometerX', MagnetometerX1, 'MagnetometerY', MagnetometerY1, 'MagnetometerZ', MagnetometerZ1, ...
    'signal_acc', signal_acc1, 'signal_gyr', signal_gyr1, 'signal_mag', signal_mag1);

 

[TimeStamp2, TimeStampUnix2, LowNoiseAccelerometerX2, LowNoiseAccelerometerY2, LowNoiseAccelerometerZ2, ...
    GyroscopeX2, GyroscopeY2, GyroscopeZ2, MagnetometerX2, MagnetometerY2, MagnetometerZ2, signal_acc2, signal_gyr2, signal_mag2] = importfileIMU(dataFile2);

 

% imu_left

 

imu_left = struct('TimeStamp', TimeStamp2, 'TimeStampUnix', TimeStampUnix2, ...
    'LowNoiseAccelerometerX', LowNoiseAccelerometerX2, 'LowNoiseAccelerometerY', LowNoiseAccelerometerY2, 'LowNoiseAccelerometerZ', LowNoiseAccelerometerZ2, ...
    'GyroscopeX', GyroscopeX2, 'GyroscopeY', GyroscopeY2, 'GyroscopeZ', GyroscopeZ2, ...
    'MagnetometerX', MagnetometerX2, 'MagnetometerY', MagnetometerY2, 'MagnetometerZ', MagnetometerZ2, ...
    'signal_acc', signal_acc2, 'signal_gyr', signal_gyr2, 'signal_mag', signal_mag2);

 

% Synch - Importar datos del sensor de sincronización

 

[TimeStamp3, TimeStampUnix3, EXG2CH2] = importfileSynch_v2(dataFile3);

synch = struct('TimeStamp', TimeStamp3, 'TimeStampUnix', TimeStampUnix3, 'EXG2CH2', EXG2CH2);

 

% Generar vectores de tiempo para los 3 sensores interpolando

% imu_right
a1 = ~isnan(TimeStampUnix1); b1 = find(a1); TimeUnix1 = TimeStampUnix1(b1);
dt1 = diff(TimeStamp1); % mean(dt1)
time_imu_right = interp1(b1, TimeUnix1, [1:length(TimeStampUnix1)]);
imu_right.interp_time = time_imu_right; 

% imu_left
a2 = ~isnan(TimeStampUnix2); b2 = find(a2); TimeUnix2 = TimeStampUnix2(b2);
dt2 = diff(TimeStamp2); % mean(dt2)
time_imu_left = interp1(b2, TimeUnix2, [1:length(TimeStampUnix2)]);
imu_left.interp_time = time_imu_left;
 

% synch
a3 = ~isnan(TimeStampUnix3); b3 = find(a3); TimeUnix3 = TimeStampUnix3(b3);
dt3 = diff(TimeStamp3); % mean(dt3)
time_synch = interp1(b3, TimeUnix3, [1:length(TimeStampUnix3)]);
synch.interp_time = time_synch;

 

% Posición (sample) en la que llega el trigger para el sensor synch

 

markers = struct();

[peaks_start, locs_start] = findpeaks(diff(EXG2CH2), 'MinPeakHeight', 70);

[peaks_stop, locs_stop] = findpeaks(-diff(EXG2CH2), 'MinPeakHeight', 70);

markers.start = locs_start;

markers.stop = locs_stop;

 

 

%-----------------------------------

marker_times_start = synch.interp_time(markers.start);

marker_times_stop = synch.interp_time(markers.stop);

 

 

 

% Realizar plots

figure;

 

% Plot de las señales de gyr de la imu_left y la señal de trigger

subplot(2, 1, 1);

plot(time_imu_left, imu_left.GyroscopeX, 'r');

hold on;

plot(time_imu_left, imu_left.GyroscopeY, 'g');

plot(time_imu_left, imu_left.GyroscopeZ, 'b');

plot(time_synch, synch.EXG2CH2 / max(abs(synch.EXG2CH2)) * 45, 'k', 'Linewidth',2);

hold off;

title('Gyroscope Signals (Left Hand) and Trigger');

legend('Gyro X', 'Gyro Y', 'Gyro Z', 'Trigger');

xlabel('Time (s)');

ylabel('Amplitude');

ylim([-50, 50]);

grid on;

 

% Plot de las señales de gyr de la imu_right y la señal de trigger

subplot(2, 1, 2);

plot(time_imu_right, imu_right.GyroscopeX, 'r');

hold on;

plot(time_imu_right, imu_right.GyroscopeY, 'g');

plot(time_imu_right, imu_right.GyroscopeZ, 'b');

plot(time_synch, synch.EXG2CH2 / max(abs(synch.EXG2CH2)) * 45, 'k','Linewidth',2);

hold off;

title('Gyroscope Signals (Right Hand) and Trigger');

legend('Gyro X', 'Gyro Y', 'Gyro Z', 'Trigger');

xlabel('Time (s)');

ylabel('Amplitude');

ylim([-50, 50]);

grid on;

 

 

 

% Verificar si los valores son válido

if length(marker_times_start) ~= 4|| length(marker_times_stop) ~= 4

    disp('Error: No se encontraron correctamente los marcadores. Seleccione manualmente.');

   

    % Crear una figure con 2 subplots

    figure;

   

    % Señal synch + señal gyr izquierda

    subplot(2,1,1);

    hold on;

    time_vector = (0:length(synch.EXG2CH2)-1) / 99.8; % Crear vector de tiempo

    % plot(time_vector, synch.EXG2CH2 / max(abs(synch.EXG2CH2)) * 50, 'k'); % Normalizar y escalar

    % plot(time_vector, imu_left.GyroscopeX, 'r');

    % plot(time_vector, imu_left.GyroscopeY, 'g');

    % plot(time_vector, imu_left.GyroscopeZ, 'b');

 

    plot(imu_left.GyroscopeX, 'r');

    plot(imu_left.GyroscopeY, 'g');

    plot(imu_left.GyroscopeZ, 'b');

    plot( synch.EXG2CH2 / max(abs(synch.EXG2CH2)) * 50, 'k'); % Normalizar y escalar

 

    hold off;

    title('Señal synch + IMU izquierda');

    xlabel('Tiempo (s)');

    ylabel('Amplitud');

    ylim([-50, 50]);

    grid on;

   

    % Señal synch + señal gyr derecha

    subplot(2,1,2);

    hold on;

    % plot(time_vector, synch.EXG2CH2 / max(abs(synch.EXG2CH2)) * 50, 'k'); % Normalizar y escalar

    % plot(time_vector, imu_right.GyroscopeX, 'r');

    % plot(time_vector, imu_right.GyroscopeY, 'g');

    % plot(time_vector, imu_right.GyroscopeZ, 'b');

    plot(imu_right.GyroscopeX, 'r');

    plot( imu_right.GyroscopeY, 'g');

    plot(imu_right.GyroscopeZ, 'b');

    plot( synch.EXG2CH2 / max(abs(synch.EXG2CH2)) * 50, 'k'); % Normalizar y escalar

 

    hold off;

    title('Señal synch + IMU derecha');

    xlabel('Tiempo (s)');

    ylabel('Amplitud');

    ylim([-50, 50]);

    grid on;

   

    % Preguntar al usuario los valores manualmente

    disp('Seleccione los 8 valores manualmente (en segundos):');

    selected_values = input('Ingrese los valores en formato [1 2 3 4 5 6 7 8]: ');

   

    % Asignar valores

    % imu_left.markers.start = selected_values([1, 3, 5, 7]);

    % imu_left.markers.stop = selected_values([2, 4, 6, 8]);

    % imu_right.markers.start = selected_values([1, 3, 5, 7]);

    % imu_right.markers.stop = selected_values([2, 4, 6, 8]);

 

    imu_left.markers.start = arrayfun(@(t) findClosestIndex(imu_left.interp_time, t), synch.interp_time(selected_values([1, 3, 5, 7])));

    imu_left.markers.stop = arrayfun(@(t) findClosestIndex(imu_left.interp_time, t), synch.interp_time(selected_values([2, 4, 6, 8])));

   

    % Encontrar las posiciones equivalentes en imu_right.interp_time

    imu_right.markers.start = arrayfun(@(t) findClosestIndex(imu_right.interp_time, t), synch.interp_time(selected_values([1, 3, 5, 7])));

    imu_right.markers.stop = arrayfun(@(t) findClosestIndex(imu_right.interp_time, t), synch.interp_time(selected_values([2, 4, 6, 8])));

else

    % Encontrar las posiciones equivalentes en imu_left.interp_time

    imu_left.markers.start = arrayfun(@(t) findClosestIndex(imu_left.interp_time, t), marker_times_start);

    imu_left.markers.stop = arrayfun(@(t) findClosestIndex(imu_left.interp_time, t), marker_times_stop);

   

    % Encontrar las posiciones equivalentes en imu_right.interp_time

    imu_right.markers.start = arrayfun(@(t) findClosestIndex(imu_right.interp_time, t), marker_times_start);

    imu_right.markers.stop = arrayfun(@(t) findClosestIndex(imu_right.interp_time, t), marker_times_stop);

end

 

 

% Calcular duración de las tareas en segundos y mostrarlas en pantalla

task_durations = (imu_right.markers.stop - imu_right.markers.start) / 99.9; % Convertir a segundos

disp('Duración de cada tarea en segundos:')

disp(task_durations)

 

% Definir nombres de las tareas

tasks = {'Resting Task', 'Dual Task', 'Resting Task 2', 'Arms Outstretched'};

numTasks = length(tasks);

gyro_left_tasks = cell(1, numTasks);

gyro_right_tasks = cell(1, numTasks);

 

% Cortar señales para cada tarea

for i = 1:numTasks

    gyro_left_tasks{i}.time = (0:length(imu_left.markers.start(i):imu_left.markers.stop(i))-1) / 99.9; % Escala en segundos

    gyro_left_tasks{i}.GyroscopeX = imu_left.GyroscopeX(imu_left.markers.start(i):imu_left.markers.stop(i));

    gyro_left_tasks{i}.GyroscopeY = imu_left.GyroscopeY(imu_left.markers.start(i):imu_left.markers.stop(i));

    gyro_left_tasks{i}.GyroscopeZ = imu_left.GyroscopeZ(imu_left.markers.start(i):imu_left.markers.stop(i));

   

    gyro_right_tasks{i}.time = (0:length(imu_right.markers.start(i):imu_right.markers.stop(i))-1) / 99.9; % Escala en segundos

    gyro_right_tasks{i}.GyroscopeX = imu_right.GyroscopeX(imu_right.markers.start(i):imu_right.markers.stop(i));

    gyro_right_tasks{i}.GyroscopeY = imu_right.GyroscopeY(imu_right.markers.start(i):imu_right.markers.stop(i));

    gyro_right_tasks{i}.GyroscopeZ = imu_right.GyroscopeZ(imu_right.markers.start(i):imu_right.markers.stop(i));

end

% Guardar los datos actualizados

save([fileName '_all_updated.mat'], 'imu_left', 'imu_right', 'synch', 'markers', 'gyro_left_tasks', 'gyro_right_tasks','gyro_left_tasks');

 

 

 

 

% Función auxiliar para encontrar el índice más cercano

function idx = findClosestIndex(timeVector, targetTime)

    [~, idx] = min(abs(timeVector - targetTime));


end