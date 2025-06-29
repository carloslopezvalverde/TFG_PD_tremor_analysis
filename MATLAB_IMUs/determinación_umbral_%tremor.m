function [DTF, P_DTF, band_power, rms_tremor, rms_robust, TPR, temblor_stats] = eleccion_umbral(signal_X, signal_Y, signal_Z, fs, plot_flag, time_vector)
    % Función para calcular PSD con método de Welch, espectrograma y métricas del temblor
    % Además, marca los puntos del espectrograma con potencia > -5 dB/Hz (amarillo claro)
    
        % Al principio de la función, puedes normalizar el vector de tiempo para que comience en 0
    if nargin < 6 || isempty(time_vector)
        time_vector = (0:length(signal_X)-1) / fs;
    else
        % Normalizar el vector de tiempo para que comience en 0
        time_vector = time_vector - time_vector(1);
    end
    
    % Duración total de la prueba tomada del vector de tiempo real
    duracion_total_prueba = time_vector(end) - time_vector(1);

    %% 1️⃣ Filtrado de las señales (Butterworth 2° orden, 3-15 Hz)
    f_low = 3;
    f_high = 15;
    [b, a] = butter(2, [f_low, f_high] / (fs / 2), 'bandpass');
    filtered_X = filtfilt(b, a, signal_X);
    filtered_Y = filtfilt(b, a, signal_Y);
    filtered_Z = filtfilt(b, a, signal_Z);

    %% 2️⃣ Cálculo del PSD con Welch
    window_time = 1.5;
    overlap_time = 0.5;
    freq_resolution = 0.1;
    window_samples = round(window_time * fs);
    overlap_samples = round(overlap_time * fs);
    nfft = round(fs / freq_resolution);
    [Pxx_X, f] = pwelch(filtered_X, window_samples, overlap_samples, nfft, fs);
    [Pxx_Y, ~] = pwelch(filtered_Y, window_samples, overlap_samples, nfft, fs);
    [Pxx_Z, ~] = pwelch(filtered_Z, window_samples, overlap_samples, nfft, fs);

    %% 3️⃣ PSD Promediado
    Pxx_avg = (Pxx_X + Pxx_Y + Pxx_Z) / 3;

    %% 4️⃣ Frecuencia Dominante del Temblor
    [~, idx_max] = max(Pxx_avg);
    DTF = f(idx_max);

    %% 5️⃣ Potencia en DTF y banda
    P_DTF = Pxx_avg(idx_max);
    band_range = [DTF - 1, DTF + 1];
    band_indices = (f >= band_range(1)) & (f <= band_range(2));
    band_power = trapz(f(band_indices), Pxx_avg(band_indices));

    %% ⃣ RMS normal del temblor (3-10 Hz)
    rms_tremor = mean([rms(filtered_X), rms(filtered_Y), rms(filtered_Z)]);

    %% 6️⃣ RMS robusto del temblor (3-10 Hz)
    rms_robust = mean([robust_rms(filtered_X), robust_rms(filtered_Y), robust_rms(filtered_Z)]);

    %% 7️⃣ Índice de Potencia del Temblor
    total_power = trapz(f, Pxx_avg);
    TPR = (band_power / total_power) * 100;

    %% 8️⃣ Cálculo del espectrograma
    [Sx, Fx, Tx] = spectrogram(filtered_X, window_samples, overlap_samples, nfft, fs);
    [Sy, Fy, Ty] = spectrogram(filtered_Y, window_samples, overlap_samples, nfft, fs);
    [Sz, Fz, Tz] = spectrogram(filtered_Z, window_samples, overlap_samples, nfft, fs);
    
    %% Guardar variables en el workspace
    assignin('base', 'Sx', Sx);
    assignin('base', 'Fx', Fx);
    assignin('base', 'Tx', Tx);
    
    assignin('base', 'Sy', Sy);
    assignin('base', 'Fy', Fy);
    assignin('base', 'Ty', Ty);
    
    assignin('base', 'Sz', Sz);
    assignin('base', 'Fz', Fz);
    assignin('base', 'Tz', Tz);
    
    %% 9️⃣ Umbral para puntos donde hay temblor
    umbral_dB_1 = 36.8;
    umbral_dB_2 = 36;
    umbral_dB_3 = 37;

    Sx_dB = 10 * log10(abs(Sx).^2);
    Sy_dB = 10 * log10(abs(Sy).^2);
    Sz_dB = 10 * log10(abs(Sz).^2);

    assignin('base', 'Sx_dB', Sx_dB);
    assignin('base', 'Sy_dB', Sy_dB);
    assignin('base', 'Sz_dB', Sz_dB);
    
    %% 🔟 Detección de intervalos y tabla
    tabla_intervalos_1 = detectar_intervalos(Tx, Fx, Sx_dB, Sx, umbral_dB_1, 'X', time_vector);
    tabla_intervalos_1 = [tabla_intervalos_1; detectar_intervalos(Ty, Fy, Sy_dB, Sy, umbral_dB_1, 'Y', time_vector)];
    tabla_intervalos_1 = [tabla_intervalos_1; detectar_intervalos(Tz, Fz, Sz_dB, Sz, umbral_dB_1, 'Z', time_vector)];
    disp('⏱️ Intervalos con potencia > umbral 1 (36.8):');
    disp(tabla_intervalos_1);

    % Guardar en base de datos (opcional)
    assignin('base', 'intervalos_temporales', tabla_intervalos_1);

    tabla_intervalos_2 = detectar_intervalos(Tx,Fx, Sx_dB,Sx, umbral_dB_2, 'X',time_vector);
    tabla_intervalos_2 = [tabla_intervalos_2; detectar_intervalos(Ty, Fy, Sy_dB,Sy, umbral_dB_2, 'Y',time_vector)];
    tabla_intervalos_2 = [tabla_intervalos_2; detectar_intervalos(Tz,Fz, Sz_dB, Sz, umbral_dB_2, 'Z',time_vector)];
    disp('⏱️ Intervalos con potencia > umbral 2 (36):');
    disp(tabla_intervalos_2);

     % Guardar en base de datos (opcional)
    assignin('base', 'intervalos_temporales', tabla_intervalos_2);

    tabla_intervalos_3 = detectar_intervalos(Tx,Fx, Sx_dB,Sx, umbral_dB_3, 'X',time_vector);
    tabla_intervalos_3 = [tabla_intervalos_3; detectar_intervalos(Ty, Fy, Sy_dB,Sy, umbral_dB_3, 'Y',time_vector)];
    tabla_intervalos_3 = [tabla_intervalos_3; detectar_intervalos(Tz,Fz, Sz_dB, Sz, umbral_dB_3, 'Z',time_vector)];
    disp('⏱️ Intervalos con potencia > umbral 3 (37):');
    disp(tabla_intervalos_3);

     % Guardar en base de datos (opcional)
    assignin('base', 'intervalos_temporales', tabla_intervalos_3);

    %% NUEVO: Calcular estadísticas de tiempo de temblor
    
    % Calcular tiempos totales de temblor para cada umbral y cada eje
    [t_temblor_1, t_temblor_porc_1] = calcular_tiempo_temblor(tabla_intervalos_1, duracion_total_prueba);
    [t_temblor_2, t_temblor_porc_2] = calcular_tiempo_temblor(tabla_intervalos_2, duracion_total_prueba);
    [t_temblor_3, t_temblor_porc_3] = calcular_tiempo_temblor(tabla_intervalos_3, duracion_total_prueba);
    
    % Crear estructura con todas las estadísticas de temblor
    temblor_stats = struct();
    temblor_stats.duracion_total_prueba = duracion_total_prueba;
    
    % Para umbral 1
    temblor_stats.umbral_1 = struct();
    temblor_stats.umbral_1.tiempo_total = t_temblor_1;
    temblor_stats.umbral_1.porcentaje = t_temblor_porc_1;
    temblor_stats.umbral_1.por_eje = calcular_tiempo_temblor_por_eje(tabla_intervalos_1, duracion_total_prueba);
    
    % Para umbral 2
    temblor_stats.umbral_2 = struct();
    temblor_stats.umbral_2.tiempo_total = t_temblor_2;
    temblor_stats.umbral_2.porcentaje = t_temblor_porc_2;
    temblor_stats.umbral_2.por_eje = calcular_tiempo_temblor_por_eje(tabla_intervalos_2, duracion_total_prueba);
    
    % Para umbral 3
    temblor_stats.umbral_3 = struct();
    temblor_stats.umbral_3.tiempo_total = t_temblor_3;
    temblor_stats.umbral_3.porcentaje = t_temblor_porc_3;
    temblor_stats.umbral_3.por_eje = calcular_tiempo_temblor_por_eje(tabla_intervalos_3, duracion_total_prueba);
    
    % Guardar en base de datos (opcional)
    assignin('base', 'temblor_stats', temblor_stats);
    
    %% Ploteo
    if plot_flag
        % [Aquí todo el código de ploteo original...]
        
        figure;
        % Espectrograma X
        subplot(3,1,1);
        imagesc(Tx, Fx, Sx_dB);       % Graficar el espectrograma en dB
        set(gca, 'YDir', 'normal');   % Orientación natural del eje Y
        ylim([0 20]);                 % Límite de frecuencia
        colormap(jet);                % Aplicar colormap
        caxis([0 60]);                % Establecer límites de colores
        colorbar;                     % Mostrar el colorbar
        title('Espectrograma - Eje X');
        xlabel('Tiempo (s)');
        ylabel('Frecuencia (Hz)');
        
        % Activar Data Cursor en el espectrograma de X
        dcmX = datacursormode(gcf);
        set(dcmX, 'Enable', 'on');
        dcmX.UpdateFcn = @(obj, event) mostrar_info_db(event, Sx_dB, Tx, Fx);
        
        % Espectrograma Y
        subplot(3,1,2);
        imagesc(Ty, Fy, Sy_dB);       % Graficar el espectrograma en dB
        set(gca, 'YDir', 'normal');   % Orientación natural del eje Y
        ylim([0 20]);                 % Límite de frecuencia
        colormap(jet);                % Aplicar colormap
        caxis([0 60]);                % Establecer límites de colores
        colorbar;                     % Mostrar el colorbar
        title('Espectrograma - Eje Y');
        xlabel('Tiempo (s)');
        ylabel('Frecuencia (Hz)');
        
        % Activar Data Cursor en el espectrograma de Y
        dcmY = datacursormode(gcf);
        set(dcmY, 'Enable', 'on');
        dcmY.UpdateFcn = @(obj, event) mostrar_info_db(event, Sy_dB, Ty, Fy);
        
        % Espectrograma Z
        subplot(3,1,3);
        imagesc(Tz, Fz, Sz_dB);       % Graficar el espectrograma en dB
        set(gca, 'YDir', 'normal');   % Orientación natural del eje Y
        ylim([0 20]);                 % Límite de frecuencia
        colormap(jet);                % Aplicar colormap
        caxis([0 60]);                % Establecer límites de colores
        colorbar;                     % Mostrar el colorbar
        title('Espectrograma - Eje Z');
        xlabel('Tiempo (s)');
        ylabel('Frecuencia (Hz)');
        
        % Activar Data Cursor en el espectrograma de Z
        dcmZ = datacursormode(gcf);
        set(dcmZ, 'Enable', 'on');
        dcmZ.UpdateFcn = @(obj, event) mostrar_info_db(event, Sz_dB, Tz, Fz);

        % Colores para cada umbral
        color_umbral1 = [1 1 0.6];    % Amarillo claro para umbral 1
        color_umbral2 = [0.3 0.8 1];  % Azul claro para umbral 2
        color_umbral3 = [1 0.5 0.7];  % Rosa para umbral 3
        
        % Figura para el eje X
        figure('Name', 'Detección de temblor - Eje X');
        for j = 1:3
            subplot(3,1,j);
            hold on;
            
            % Seleccionar tabla según umbral
            if j == 1
                tabla_filtrada = tabla_intervalos_1(strcmp(tabla_intervalos_1.Eje, 'X'), :);
                color_umbral = color_umbral1;
                valor_umbral = umbral_dB_1;
            elseif j == 2
                tabla_filtrada = tabla_intervalos_2(strcmp(tabla_intervalos_2.Eje, 'X'), :);
                color_umbral = color_umbral2;
                valor_umbral = umbral_dB_2;
            else
                tabla_filtrada = tabla_intervalos_3(strcmp(tabla_intervalos_3.Eje, 'X'), :);
                color_umbral = color_umbral3;
                valor_umbral = umbral_dB_3;
            end
            
            % Pintar zonas de temblor
            for k = 1:height(tabla_filtrada)
                x1 = tabla_filtrada.Inicio_s(k) * fs;
                x2 = tabla_filtrada.Fin_s(k) * fs;
                
                if tabla_filtrada.Duracion_s(k) == 0
                    area([x1 x2+1], [50 50], -50, 'FaceColor', [1 0.5 0], 'EdgeColor', 'none'); % naranja para puntos aislados
                else
                    area([x1 x2], [50 50], -50, 'FaceColor', color_umbral, 'EdgeColor', 'none'); 
                end
            end
            
            % Plot señal original y filtrada
            plot(signal_X, 'b');
            plot(filtered_X, 'r');
            ylim([-50 50]);
            title(['Señal X con detección de temblor - Umbral ' num2str(j) ' (' num2str(valor_umbral) ' dB)']);
            xlabel('Muestras');
            ylabel('Amplitud');
            grid on;
        end
        
        % Figura para el eje Y
        figure('Name', 'Detección de temblor - Eje Y');
        for j = 1:3
            subplot(3,1,j);
            hold on;
            
            % Seleccionar tabla según umbral
            if j == 1
                tabla_filtrada = tabla_intervalos_1(strcmp(tabla_intervalos_1.Eje, 'Y'), :);
                color_umbral = color_umbral1;
                valor_umbral = umbral_dB_1;
            elseif j == 2
                tabla_filtrada = tabla_intervalos_2(strcmp(tabla_intervalos_2.Eje, 'Y'), :);
                color_umbral = color_umbral2;
                valor_umbral = umbral_dB_2;
            else
                tabla_filtrada = tabla_intervalos_3(strcmp(tabla_intervalos_3.Eje, 'Y'), :);
                color_umbral = color_umbral3;
                valor_umbral = umbral_dB_3;
            end
            
            % Pintar zonas de temblor
            for k = 1:height(tabla_filtrada)
                x1 = tabla_filtrada.Inicio_s(k) * fs;
                x2 = tabla_filtrada.Fin_s(k) * fs;
                
                if tabla_filtrada.Duracion_s(k) == 0
                    area([x1 x2+1], [50 50], -50, 'FaceColor', [1 0.5 0], 'EdgeColor', 'none'); % naranja para puntos aislados
                else
                    area([x1 x2], [50 50], -50, 'FaceColor', color_umbral, 'EdgeColor', 'none'); 
                end
            end
            
            % Plot señal original y filtrada
            plot(signal_Y, 'g');
            plot(filtered_Y, 'r');
            ylim([-50 50]);
            title(['Señal Y con detección de temblor - Umbral ' num2str(j) ' (' num2str(valor_umbral) ' dB)']);
            xlabel('Muestras');
            ylabel('Amplitud');
            grid on;
        end
        
        % Figura para el eje Z
        figure('Name', 'Detección de temblor - Eje Z');
        for j = 1:3
            subplot(3,1,j);
            hold on;
            
            % Seleccionar tabla según umbral
            if j == 1
                tabla_filtrada = tabla_intervalos_1(strcmp(tabla_intervalos_1.Eje, 'Z'), :);
                color_umbral = color_umbral1;
                valor_umbral = umbral_dB_1;
            elseif j == 2
                tabla_filtrada = tabla_intervalos_2(strcmp(tabla_intervalos_2.Eje, 'Z'), :);
                color_umbral = color_umbral2;
                valor_umbral = umbral_dB_2;
            else
                tabla_filtrada = tabla_intervalos_3(strcmp(tabla_intervalos_3.Eje, 'Z'), :);
                color_umbral = color_umbral3;
                valor_umbral = umbral_dB_3;
            end
            
            % Pintar zonas de temblor
            for k = 1:height(tabla_filtrada)
                x1 = tabla_filtrada.Inicio_s(k) * fs;
                x2 = tabla_filtrada.Fin_s(k) * fs;
                
                if tabla_filtrada.Duracion_s(k) == 0
                    area([x1 x2+1], [50 50], -50, 'FaceColor', [1 0.5 0], 'EdgeColor', 'none'); % naranja para puntos aislados
                else
                    area([x1 x2], [50 50], -50, 'FaceColor', color_umbral, 'EdgeColor', 'none'); 
                end
            end
            
            % Plot señal original y filtrada
            plot(signal_Z, 'm');
            plot(filtered_Z, 'r');
            ylim([-50 50]);
            title(['Señal Z con detección de temblor - Umbral ' num2str(j) ' (' num2str(valor_umbral) ' dB)']);
            xlabel('Muestras');
            ylabel('Amplitud');
            grid on;
        end
        
        % NUEVO: Gráfico comparativo de tiempos de temblor
        figure('Name', 'Estadísticas de tiempo de temblor');
        
        % Configuración del gráfico de barras
        ejes = {'X', 'Y', 'Z', 'Media'};
        umbrales = [umbral_dB_1, umbral_dB_2, umbral_dB_3];
        
        % Preparar datos para el gráfico de barras
        % Preparar datos para el gráfico de barras
        tiempos_umbral1 = [temblor_stats.umbral_1.por_eje.X.tiempo_total, ...
                          temblor_stats.umbral_1.por_eje.Y.tiempo_total, ...
                          temblor_stats.umbral_1.por_eje.Z.tiempo_total, ...
                          mean([temblor_stats.umbral_1.por_eje.X.tiempo_total, ...
                                temblor_stats.umbral_1.por_eje.Y.tiempo_total, ...
                                temblor_stats.umbral_1.por_eje.Z.tiempo_total])];
                          
        tiempos_umbral2 = [temblor_stats.umbral_2.por_eje.X.tiempo_total, ...
                          temblor_stats.umbral_2.por_eje.Y.tiempo_total, ...
                          temblor_stats.umbral_2.por_eje.Z.tiempo_total, ...
                          mean([temblor_stats.umbral_2.por_eje.X.tiempo_total, ...
                                temblor_stats.umbral_2.por_eje.Y.tiempo_total, ...
                                temblor_stats.umbral_2.por_eje.Z.tiempo_total])];
                          
        tiempos_umbral3 = [temblor_stats.umbral_3.por_eje.X.tiempo_total, ...
                          temblor_stats.umbral_3.por_eje.Y.tiempo_total, ...
                          temblor_stats.umbral_3.por_eje.Z.tiempo_total, ...
                          mean([temblor_stats.umbral_3.por_eje.X.tiempo_total, ...
                                temblor_stats.umbral_3.por_eje.Y.tiempo_total, ...
                                temblor_stats.umbral_3.por_eje.Z.tiempo_total])];
        
        % Colores para cada umbral
        color_umbral1 = [1 1 0.6];    % Amarillo claro para umbral 1
        color_umbral2 = [0.3 0.8 1];  % Azul claro para umbral 2
        color_umbral3 = [1 0.5 0.7];  % Rosa para umbral 3
        
        % Gráfico de barras de tiempo absoluto
        subplot(2,1,1);
        h1 = bar([tiempos_umbral1; tiempos_umbral2; tiempos_umbral3]');
        colores = [color_umbral1; color_umbral2; color_umbral3];
        for k = 1:length(h1)
            h1(k).FaceColor = 'flat';
            h1(k).CData = repmat(colores(k, :), size(h1(k).CData, 1), 1);
        end
        title('Tiempo de temblor por eje y umbral');
        xlabel('Eje');
        ylabel('Tiempo (s)');
        set(gca, 'XTickLabel', ejes);
        legend({['Umbral 1 (' num2str(umbral_dB_1) ' dB)'], ...
                ['Umbral 2 (' num2str(umbral_dB_2) ' dB)'], ...
                ['Umbral 3 (' num2str(umbral_dB_3) ' dB)']}, ...
                'Location', 'best');
        ylim([0 duracion_total_prueba]); 
        grid on;
        
        % Gráfico de barras de porcentaje de tiempo
        % Gráfico de barras de porcentaje de tiempo
        porcentajes_umbral1 = [temblor_stats.umbral_1.por_eje.X.porcentaje, ...
                               temblor_stats.umbral_1.por_eje.Y.porcentaje, ...
                               temblor_stats.umbral_1.por_eje.Z.porcentaje, ...
                               mean([temblor_stats.umbral_1.por_eje.X.porcentaje, ...
                                     temblor_stats.umbral_1.por_eje.Y.porcentaje, ...
                                     temblor_stats.umbral_1.por_eje.Z.porcentaje])];
                          
        porcentajes_umbral2 = [temblor_stats.umbral_2.por_eje.X.porcentaje, ...
                               temblor_stats.umbral_2.por_eje.Y.porcentaje, ...
                               temblor_stats.umbral_2.por_eje.Z.porcentaje, ...
                               mean([temblor_stats.umbral_2.por_eje.X.porcentaje, ...
                                     temblor_stats.umbral_2.por_eje.Y.porcentaje, ...
                                     temblor_stats.umbral_2.por_eje.Z.porcentaje])];
                          
        porcentajes_umbral3 = [temblor_stats.umbral_3.por_eje.X.porcentaje, ...
                               temblor_stats.umbral_3.por_eje.Y.porcentaje, ...
                               temblor_stats.umbral_3.por_eje.Z.porcentaje, ...
                               mean([temblor_stats.umbral_3.por_eje.X.porcentaje, ...
                                     temblor_stats.umbral_3.por_eje.Y.porcentaje, ...
                                     temblor_stats.umbral_3.por_eje.Z.porcentaje])];
        
        subplot(2,1,2);
        h2 = bar([porcentajes_umbral1; porcentajes_umbral2; porcentajes_umbral3]');
        for k = 1:length(h2)
            h2(k).FaceColor = 'flat';
            h2(k).CData = repmat(colores(k, :), size(h2(k).CData, 1), 1);
        end
        title('Porcentaje de tiempo con temblor por eje y umbral');
        xlabel('Eje');
        ylabel('Porcentaje (%)');
        set(gca, 'XTickLabel', ejes);
        legend({['Umbral 1 (' num2str(umbral_dB_1) ' dB)'], ...
                ['Umbral 2 (' num2str(umbral_dB_2) ' dB)'], ...
                ['Umbral 3 (' num2str(umbral_dB_3) ' dB)']}, ...
                'Location', 'best');
        ylim([0 100]);
        grid on;

    end

    fprintf('\n📊 Resultados:\n');
    fprintf('Frecuencia Dominante del Temblor (DTF):       %.4f Hz\n', DTF);
    fprintf('Potencia en la DTF (P_DTF):                    %.4f\n', P_DTF);
    fprintf('Potencia en banda ±1 Hz alrededor de DTF:     %.4f\n', band_power);
    fprintf('RMS robusto del temblor:                      %.4f\n', rms_tremor);
    fprintf('Índice de Potencia del Temblor (TPR):         %.4f %%\n', TPR);
    
    % NUEVO: Mostrar estadísticas de tiempo de temblor
    fprintf('\n⏱️ Estadísticas de tiempo de temblor:\n');
    fprintf('Duración total de la prueba:                  %.2f segundos\n', duracion_total_prueba);
    
    % Estadísticas para umbral 1
    fprintf('\nUmbral 1 (%.1f dB):\n', umbral_dB_1);
%     fprintf('  Tiempo total con temblor:                   %.2f segundos\n', temblor_stats.umbral_1.tiempo_total);
%     fprintf('  Porcentaje de tiempo con temblor:           %.2f %%\n', temblor_stats.umbral_1.porcentaje);
    fprintf('  Por eje - X: %.2fs (%.2f%%), Y: %.2fs (%.2f%%), Z: %.2fs (%.2f%%)\n', ...
        temblor_stats.umbral_1.por_eje.X.tiempo_total, temblor_stats.umbral_1.por_eje.X.porcentaje, ...
        temblor_stats.umbral_1.por_eje.Y.tiempo_total, temblor_stats.umbral_1.por_eje.Y.porcentaje, ...
        temblor_stats.umbral_1.por_eje.Z.tiempo_total, temblor_stats.umbral_1.por_eje.Z.porcentaje);
    
    % Estadísticas para umbral 2
    fprintf('\nUmbral 2 (%.1f dB):\n', umbral_dB_2);
%     fprintf('  Tiempo total con temblor:                   %.2f segundos\n', temblor_stats.umbral_2.tiempo_total);
%     fprintf('  Porcentaje de tiempo con temblor:           %.2f %%\n', temblor_stats.umbral_2.porcentaje);
    fprintf('  Por eje - X: %.2fs (%.2f%%), Y: %.2fs (%.2f%%), Z: %.2fs (%.2f%%)\n', ...
        temblor_stats.umbral_2.por_eje.X.tiempo_total, temblor_stats.umbral_2.por_eje.X.porcentaje, ...
        temblor_stats.umbral_2.por_eje.Y.tiempo_total, temblor_stats.umbral_2.por_eje.Y.porcentaje, ...
        temblor_stats.umbral_2.por_eje.Z.tiempo_total, temblor_stats.umbral_2.por_eje.Z.porcentaje);
    
    % Estadísticas para umbral 3
    fprintf('\nUmbral 3 (%.1f dB):\n', umbral_dB_3);
%     fprintf('  Tiempo total con temblor:                   %.2f segundos\n', temblor_stats.umbral_3.tiempo_total);
%     fprintf('  Porcentaje de tiempo con temblor:           %.2f %%\n', temblor_stats.umbral_3.porcentaje);
    fprintf('  Por eje - X: %.2fs (%.2f%%), Y: %.2fs (%.2f%%), Z: %.2fs (%.2f%%)\n', ...
        temblor_stats.umbral_3.por_eje.X.tiempo_total, temblor_stats.umbral_3.por_eje.X.porcentaje, ...
        temblor_stats.umbral_3.por_eje.Y.tiempo_total, temblor_stats.umbral_3.por_eje.Y.porcentaje, ...
        temblor_stats.umbral_3.por_eje.Z.tiempo_total, temblor_stats.umbral_3.por_eje.Z.porcentaje);
end

function rms_robust = robust_rms(signal, lower_percentile, upper_percentile)
    if nargin < 2
        lower_percentile = 10;
    end
    if nargin < 3
        upper_percentile = 90;
    end
    p_low = prctile(signal, lower_percentile);
    p_high = prctile(signal, upper_percentile);
    trimmed_signal = signal(signal >= p_low & signal <= p_high);
    rms_robust = sqrt(mean(trimmed_signal.^2));
end

function tabla = detectar_intervalos(T, F, S_dB, S, umbral, eje, time_vector)
    % Identificar los tiempos donde alguna frecuencia supera el umbral
    potentes = any(S_dB > umbral, 1);  % Vector lógico del tamaño de T
    cambios = diff([0, potentes, 0]);  % Detecta cambios de estado

    inicios = find(cambios == 1);
    finales = find(cambios == -1) - 1;

    % Crear tabla con los intervalos detectados
    tabla = table();
    for k = 1:length(inicios)
        % Obtener los tiempos reales del espectrograma
        tiempo_inicio_spec = T(inicios(k));
        tiempo_fin_spec = T(finales(k));
        
        % Tratamiento especial para los extremos
        if inicios(k) == 1  % Si el intervalo empieza en el primer punto del espectrograma
            tiempo_inicio = time_vector(1);  % Usar el tiempo inicial real
        else
            % Encontrar el índice más cercano en el vector de tiempo original
            [~, idx_inicio] = min(abs(time_vector - tiempo_inicio_spec));
            tiempo_inicio = time_vector(idx_inicio);
        end
        
        if finales(k) == length(T)  % Si el intervalo termina en el último punto del espectrograma
            tiempo_fin = time_vector(end);  % Usar el tiempo final real
        else
            % Encontrar el índice más cercano en el vector de tiempo original
            [~, idx_fin] = min(abs(time_vector - tiempo_fin_spec));
            tiempo_fin = time_vector(idx_fin);
        end
        
        % Asegurar que los intervalos están ordenados correctamente
        if tiempo_fin < tiempo_inicio
            temp = tiempo_fin;
            tiempo_fin = tiempo_inicio;
            tiempo_inicio = temp;
        end
        
        duracion = tiempo_fin - tiempo_inicio;  % Duración del intervalo

        % Valores de potencia espectral (no normalizados)
        potencia_inicio = S(:, inicios(k));
        potencia_fin = S(:, finales(k));

        potencia_inicio_val = round(mean(abs(potencia_inicio).^2), 3);
        potencia_fin_val = round(mean(abs(potencia_fin).^2), 3);

        % Potencia en dB completa para inicio y fin
        potencia_inicio_dB_vec = S_dB(:, inicios(k));
        potencia_fin_dB_vec = S_dB(:, finales(k));

        % Frecuencia con máxima potencia al inicio y final
        [potencia_inicio_dB, idx_inicio_f] = max(potencia_inicio_dB_vec);
        [potencia_fin_dB, idx_fin_f] = max(potencia_fin_dB_vec);

        frec_inicio = F(idx_inicio_f);
        frec_fin = F(idx_fin_f);

        % Crear fila con los datos (con duración añadida)
        fila = table({eje}, duracion, tiempo_inicio, tiempo_fin, frec_inicio, frec_fin, ...
                     potencia_inicio_dB, potencia_fin_dB, ...
                     'VariableNames', {'Eje', 'Duracion_s', 'Inicio_s', 'Fin_s', ...
                     'Frec_Inicio_Hz', 'Frec_Fin_Hz', ...
                     'Potencia_Inicio_dB', 'Potencia_Fin_dB'});

        % Agregar fila a la tabla
        tabla = [tabla; fila];
    end
end

function output_txt = mostrar_info_db(event_obj, S_dB, T, F)
    pos = event_obj.Position;

    % Índices más cercanos en tiempo y frecuencia
    [~, idx_t] = min(abs(T - pos(1)));
    [~, idx_f] = min(abs(F - pos(2)));

    valor_db = S_dB(idx_f, idx_t);  % filas: freq, columnas: tiempo

    output_txt = {
        ['Tiempo: ', num2str(T(idx_t), '%.2f'), ' s'], ...
        ['Frecuencia: ', num2str(F(idx_f), '%.2f'), ' Hz'], ...
        ['Potencia: ', num2str(valor_db, '%.2f'), ' dB']
    };
end

% NUEVAS FUNCIONES PARA ESTADÍSTICAS DE TIEMPO DE TEMBLOR

function [tiempo_total, porcentaje] = calcular_tiempo_temblor(tabla_intervalos, duracion_total)
    % Esta función calcula el tiempo total de temblor consolidando 
    % los intervalos que se solapan entre los diferentes ejes
    if isempty(tabla_intervalos)
        tiempo_total = 0;
        porcentaje = 0;
        return;
    end
    
    % Unir todos los intervalos, incluso si se solapan
    todos_intervalos = [];
    for i = 1:height(tabla_intervalos)
        todos_intervalos = [todos_intervalos; tabla_intervalos.Inicio_s(i), tabla_intervalos.Fin_s(i)];
    end
    
    % Ordenar los intervalos por tiempo de inicio
    todos_intervalos = sortrows(todos_intervalos, 1);
    
    % Consolidar intervalos solapados
    intervalos_consolidados = [todos_intervalos(1, :)];
    idx_actual = 1;
    
    for i = 2:size(todos_intervalos, 1)
        % Si el intervalo actual empieza antes de que termine el último consolidado
        if todos_intervalos(i, 1) <= intervalos_consolidados(idx_actual, 2)
            % Actualizar el tiempo final si el nuevo intervalo termina después
            intervalos_consolidados(idx_actual, 2) = max(intervalos_consolidados(idx_actual, 2), todos_intervalos(i, 2));
        else
            % Agregar un nuevo intervalo consolidado
            idx_actual = idx_actual + 1;
            intervalos_consolidados(idx_actual, :) = todos_intervalos(i, :);
        end
    end
    
    % Calcular el tiempo total sumando las duraciones de los intervalos consolidados
    duraciones = intervalos_consolidados(:, 2) - intervalos_consolidados(:, 1);
    tiempo_total = sum(duraciones);
    
    % Calcular el porcentaje
    porcentaje = (tiempo_total / duracion_total) * 100;
end

function stats_por_eje = calcular_tiempo_temblor_por_eje(tabla_intervalos, duracion_total)
    % Esta función calcula el tiempo de temblor separado por cada eje
    stats_por_eje = struct();
    
    % Inicializar estructura para cada eje
    ejes = {'X', 'Y', 'Z'};
    for i = 1:length(ejes)
        eje = ejes{i};
        
        % Filtrar tabla para este eje
        tabla_eje = tabla_intervalos(strcmp(tabla_intervalos.Eje, eje), :);
        
        if isempty(tabla_eje)
            stats_por_eje.(eje).tiempo_total = 0;
            stats_por_eje.(eje).porcentaje = 0;
            stats_por_eje.(eje).intervalos = [];
        else
            % Calcular tiempo total para este eje (considerando posibles solapamientos)
            [tiempo_total_eje, porcentaje_eje] = calcular_tiempo_temblor(tabla_eje, duracion_total);
            
            stats_por_eje.(eje).tiempo_total = tiempo_total_eje;
            stats_por_eje.(eje).porcentaje = porcentaje_eje;
            stats_por_eje.(eje).intervalos = tabla_eje;
        end
    end
end