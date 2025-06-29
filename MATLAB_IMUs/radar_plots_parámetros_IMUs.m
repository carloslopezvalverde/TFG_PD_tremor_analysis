% radar_tremor_analysis.m
% Script para análisis de parámetros de temblor mediante gráficos radar
% El código crea gráficos radar que comparan parámetros entre grupos PRE, POST y POST24

function graficos_spider_parametros()
    % Cargar datos desde el archivo Excel
    data = readtable('Subject_01_gyro_results.xlsx');

    % Extraer número de sujeto del nombre del archivo
    filename = 'Subject_01_gyro_results.xlsx';
    subject_num = extractBetween(filename, 'Subject_', '_gyro');

    % Combinar todos los parámetros en un solo array
    parametros = {'P_DTF', 'BandPower', 'Porcentaje_Temblor_Medio', 'RMS_Tremor', 'RMS_Robust', 'TPR'};
    
    % Nombres más legibles para mostrar en los gráficos
    nombres_visualizacion = {'P DTF', 'Band Power', '%Tremor', 'RMS', 'RMS Robust', 'TPR'};

    nombre_tareas = {'RE 1', 'DT', 'RE 2', 'AO'};
    grupos = {'PRE', 'POST', 'POST24'};

    % Colores para grupos temporales
    color_grupo = {[0.0 0.4 0.8], [0.0 0.6 0.3], [0.8 0.4 0.0]}; % Azul, Verde, Naranja para PRE, POST, POST24

    % Crear una figura grande para contener todos los subplots
    figure('Color', 'w', 'Position', [100, 100, 1200, 800]);

    % Determinar el lado afectado (asumiendo que es el mismo para todo el dataset)
    lado_afectado = unique(data.Lado_Mas_Afectado);
    disp(['Lado afectado: ', lado_afectado{1}]);

    % Solo procesar el lado afectado
    lado = lado_afectado{1}; % 'left' o 'right'
    lado_nombre = '';
    if strcmp(lado, 'left')
        lado_nombre = 'Izquierdo';
    else
        lado_nombre = 'Derecho';
    end

    % Encontrar valores máximos globales de las MEDIAS por parámetro para todo el conjunto de datos
    % para normalizar todos los plots con la misma escala
    valores_maximos_globales = zeros(length(parametros), 1);

    for p = 1:length(parametros)
        parametro = parametros{p};
        medias_valores = [];
        
        % Recopilar las MEDIAS de los valores para cada grupo, tarea y sesión
        for sesion = 1:2
            for tarea = 1:4
                for j = 1:length(grupos)
                    tipo = grupos{j};
                    
                    idx = strcmp(data.Lado, lado) & (data.Tarea == tarea) ...
                          & strcmp(data.Tipo, tipo) & (data.NumPrueba <= 3) ...
                          & (data.Sesion == sesion);
                    subdata = data(idx, :);
                    
                    if ~isempty(subdata)
                        valores = subdata{:, parametro};
                        % Calcular la media para este grupo/tarea/sesión
                        media = mean(valores);
                        medias_valores = [medias_valores; media];
                    end
                end
            end
        end
        
        % Guardar el valor máximo global de las MEDIAS
        if ~isempty(medias_valores)
            valores_maximos_globales(p) = max(medias_valores);
            if valores_maximos_globales(p) == 0
                valores_maximos_globales(p) = 1; % Evitar división por cero
            end
        else
            valores_maximos_globales(p) = 1; % Valor predeterminado si no hay datos
        end
    end

    % Añadir títulos para columnas (tareas)
    for tarea = 1:4
        annotation('textbox', [0.1+(tarea-1)*0.21, 0.87, 0.2, 0.04], ...
            'String', nombre_tareas{tarea}, ...
            'EdgeColor', 'none', ...
            'HorizontalAlignment', 'center', ...
            'FontSize', 12, ...
            'FontWeight', 'bold');
    end

    % Almacenar todos los datos para tooltips
    datos_medias_completos = cell(2, 4, length(grupos), length(parametros));

    % Crear matriz para los subplots (2 sesiones x 4 tareas)
    for sesion = 1:2
        % Añadir etiqueta de sesión a la izquierda
        if sesion == 1
            annotation('textbox', [0.01, 0.62, 0.05, 0.05], ...
                'String', 'STIM', ...
                'EdgeColor', 'none', ...
                'HorizontalAlignment', 'center', ...
                'FontSize', 14, ...
                'FontWeight', 'bold');
        else
            annotation('textbox', [0.01, 0.25, 0.05, 0.05], ...
                'String', 'SHAM', ...
                'EdgeColor', 'none', ...
                'HorizontalAlignment', 'center', ...
                'FontSize', 14, ...
                'FontWeight', 'bold');
        end
        
        for tarea = 1:4
            % Calcular la posición del subplot (2 filas, 4 columnas)
            subplot_pos = (sesion-1)*4 + tarea;
            ax = subplot(2, 4, subplot_pos);
            
            % Ajustar la posición vertical de los gráficos superiores
            if sesion == 1
                pos = get(ax, 'Position');
                % Bajar la posición y ajustar la altura para mantener el tamaño
                new_pos = [pos(1), pos(2)-0.1, pos(3), pos(4)];
                set(ax, 'Position', new_pos);
            end

            % Crear contenedor para datos de los grupos
            medias_grupos = zeros(length(grupos), length(parametros));
            medias_originales = zeros(length(grupos), length(parametros));
            
            % Ahora calculamos las medias y las normalizamos con los valores máximos globales
            for j = 1:length(grupos)
                tipo = grupos{j};
                
                for p = 1:length(parametros)
                    parametro = parametros{p};
                    
                    idx = strcmp(data.Lado, lado) & (data.Tarea == tarea) ...
                          & strcmp(data.Tipo, tipo) & (data.NumPrueba <= 3) ...
                          & (data.Sesion == sesion);
                    subdata = data(idx, :);
                    
                    if ~isempty(subdata)
                        valores = subdata{:, parametro};
                        media = mean(valores);
                        % Guardar la media original para el tooltip
                        medias_originales(j, p) = media;
                        % Normalizar el valor para el gráfico radar usando la escala global
                        medias_grupos(j, p) = media / valores_maximos_globales(p);
                        % Almacenar datos originales para tooltips
                        datos_medias_completos{sesion, tarea, j, p} = media;
                    end
                end
            end
            
            % Crear el gráfico radar
            % Añadir un punto extra para cerrar el polígono
            angulos = linspace(0, 2*pi, length(parametros)+1);
            
            % Crear los ejes del radar y las etiquetas
            ax = gca;
            hold on;
            
            % Dibujar los ejes del radar
            for i = 1:length(parametros)
                % Dibujar línea desde el centro al borde
                plot([0, cos(angulos(i))], [0, sin(angulos(i))], 'k-', 'LineWidth', 0.5);
                
                % Añadir pequeñas marcas en cada eje a intervalos regulares
                for r_mark = 0.2:0.2:0.8
                    x_mark = r_mark * cos(angulos(i));
                    y_mark = r_mark * sin(angulos(i));
                    plot(x_mark, y_mark, 'k.', 'MarkerSize', 3, 'Color', [0.5 0.5 0.5]);
                end
                
                % Añadir etiqueta del parámetro
                % Ajustar alineación del texto según la posición
                halign = 'center';
                valign = 'middle';
                
                % Calcular el ángulo para este parámetro
                % Ajustar la alineación horizontal según la posición angular
                if abs(cos(angulos(i))) > 0.7
                    if cos(angulos(i)) > 0
                        halign = 'left';
                    else
                        halign = 'right';
                    end
                end
                
                % Ajustar alineación vertical según la posición angular
                if abs(sin(angulos(i))) > 0.7
                    if sin(angulos(i)) > 0
                        valign = 'bottom';
                    else
                        valign = 'top';
                    end
                end
                
               % Factor base para la distancia de la etiqueta al círculo
                % Establecer factor de separación según el parámetro
                if strcmp(parametros{i}, 'P_DTF') || strcmp(parametros{i}, 'RMS_Tremor')
                    label_factor = 1.00; % Factor más cercano para P_DTF y RMS_Tremor
                else
                    label_factor = 1.20; % Factor estándar para el resto de parámetros
                end
                
                x_pos = label_factor*cos(angulos(i));
                y_pos = label_factor*sin(angulos(i));
                
                % Ajustar posición vertical específica para P_DTF y RMS_Tremor
                if strcmp(parametros{i}, 'P_DTF')
                    % Subir la etiqueta P_DTF (añadir desplazamiento vertical positivo)
                    y_pos = y_pos + 0.08;
                elseif strcmp(parametros{i}, 'RMS_Tremor')
                    % Bajar la etiqueta RMS_Tremor (añadir desplazamiento vertical negativo)
                    y_pos = y_pos - 0.08;
                end
                
                % Usar los nombres legibles en lugar de los nombres con guiones bajos
                text(x_pos, y_pos, nombres_visualizacion{i}, ...
                    'HorizontalAlignment', halign, 'VerticalAlignment', valign, 'FontSize', 8);
                
        
                
                % Añadir valor máximo en el punto exacto del eje (en el borde exterior)
                valor_max_txt = sprintf('%.2f', valores_maximos_globales(i));
                
                % Ajustar la alineación del texto según la posición en el círculo
                halign = 'center';
                valign = 'middle';
                
                % Ajustar alineación horizontal según la posición angular
                if abs(cos(angulos(i))) > 0.7
                    if cos(angulos(i)) > 0
                        halign = 'left';
                    else
                        halign = 'right';
                    end
                end
                
                % Ajustar alineación vertical según la posición angular
                if abs(sin(angulos(i))) > 0.7
                    if sin(angulos(i)) > 0
                        valign = 'bottom';
                    else
                        valign = 'top';
                    end
                end
                
                % Colocar el valor máximo exactamente en el extremo del eje
                text(1.05*cos(angulos(i)), 1.05*sin(angulos(i)), valor_max_txt, ...
                    'HorizontalAlignment', halign, 'VerticalAlignment', valign, ...
                    'FontSize', 7, 'Color', [0.4 0.4 0.4]);
            end
            
            % Dibujar círculos concéntricos
            theta = linspace(0, 2*pi, 100);
            % Mostrar más círculos concéntricos para mejorar la visualización
            for r = 0.2:0.2:1
                x_circle = r * cos(theta);
                y_circle = r * sin(theta);
                plot(x_circle, y_circle, 'k:', 'LineWidth', 0.5, 'Color', [0.7 0.7 0.7]);
            end
            
            % Dibujar los datos para cada grupo
            h_puntos = cell(length(grupos), length(parametros));
            for j = 1:length(grupos)
                % Cerrar el polígono repitiendo el primer punto
                valores_radar = [medias_grupos(j, :), medias_grupos(j, 1)];
                
                % Calcular las coordenadas x e y
                x_radar = valores_radar .* cos(angulos);
                y_radar = valores_radar .* sin(angulos);
                
                % Dibujar el polígono relleno con transparencia
                fill(x_radar, y_radar, color_grupo{j}, 'FaceAlpha', 0.2, 'EdgeColor', color_grupo{j}, 'LineWidth', 1.5);
                
                % Marcar los puntos específicos y guardar referencias para tooltips
                for p = 1:length(parametros)
                    x_punto = medias_grupos(j, p) * cos(angulos(p));
                    y_punto = medias_grupos(j, p) * sin(angulos(p));
                    
                    h_puntos{j, p} = scatter(x_punto, y_punto, 36, color_grupo{j}, 'filled', 'MarkerEdgeColor', 'k');
                    
                    % Configurar el callback para mostrar el valor original al pasar el ratón
                    set(h_puntos{j, p}, 'UserData', struct('valor', medias_originales(j, p), ...
                                                         'grupo', grupos{j}, ...
                                                         'parametro', parametros{p}));
                end
            end
            
            % Configurar el aspecto del gráfico
            axis tight equal off;
        end
    end

    % Añadir leyenda centralizada abajo
    h_legend = zeros(1, length(grupos));
    for j = 1:length(grupos)
        h_legend(j) = plot(NaN, NaN, 'LineWidth', 2, 'Color', color_grupo{j}, 'Marker', 'o', 'MarkerFaceColor', color_grupo{j}, 'MarkerEdgeColor', 'k', 'MarkerSize', 8);
    end
    leg = legend(h_legend, grupos, 'Orientation', 'horizontal');
    leg.Position = [0.35, 0.02, 0.3, 0.05];
    leg.Box = 'off';

    % Título general con el número de sujeto
    sgtitle(['Sujeto 01 - Comparación de parámetros - Brazo Estimulado: ', lado_nombre], 'FontSize', 16, 'FontWeight', 'bold');

    % Optimizar el espacio de la figura
    set(gcf, 'Position', [100, 100, 1100, 800]);

    % Activar el modo de cursor de datos para tooltips
    dcm_obj = datacursormode(gcf);
    set(dcm_obj, 'UpdateFcn', @customDatatipFunction);
    datacursormode on;
end

% Añadir esta función de ayuda al final del archivo
function nombreLegible = obtenerNombreLegible(nombreParametro)
    switch nombreParametro
        case 'P_DTF'
            nombreLegible = 'P DTF';
        case 'BandPower'
            nombreLegible = 'Band Power';
        case 'Porcentaje_Temblor_Medio'
            nombreLegible = 'Porcentaje Temblor';
        case 'RMS_Tremor'
            nombreLegible = 'RMS Tremor';
        case 'RMS_Robust'
            nombreLegible = 'RMS Robust';
        case 'TPR'
            nombreLegible = 'TPR';
        otherwise
            nombreLegible = nombreParametro;
    end
end

% Modificar la función customDatatipFunction
function txt = customDatatipFunction(~, event_obj)
    target = get(event_obj, 'Target');
    userData = get(target, 'UserData');
    
    if ~isempty(userData)
        txt = {['Grupo: ', userData.grupo], ...
               ['Parámetro: ', obtenerNombreLegible(userData.parametro)], ...
               ['Valor: ', num2str(userData.valor, '%.3f')]};
    else
        txt = 'No hay datos disponibles';
    end
end