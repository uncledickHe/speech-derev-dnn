clearvars
clc

directorio= uigetdir('/Volumes/Boot/00Files-tesis', 'Seleccione los archivos a analizar');
files= dir(fullfile(directorio, '*.mat'));   %nombres de los archivos
directorio_salida= uigetdir('/Volumes/Boot/00Files-tesis', 'Seleccione el directorio de salida');

cant_archivos = length(files);                                      %cantidad de archivos
frames_package = 6;                                                 %cuantos frames vecinos entran en el feature vector

for ii=1:cant_archivos                                              %Loop de archivos
    archivo = files(ii).name;                                       %nombre archivo .mat
    data = load(strcat(directorio,'/',archivo),'transformada');     %Carga del contenido del .mat
    data = data.transformada;                                       %Carga del contenido del .mat
    %extraccion de datos
    data_mag_raw = abs(data);                                           %Magnitud de la STFT
    data_mag = data_mag_raw(:);                                         %Vector columna de la magnitud
    data_phase_raw = angle(data);                                       %Fase de la STFT
    data_phase = data_phase_raw(:);                                     %Vector columna de la fase
    [filas, columnas] = size(data_mag);                                 %Tamano de la matriz de mag o fase en columna del stack
    [filas_raw, columnas_raw] = size(data_mag_raw);                     %Tamano de la matriz de mag o fase en columna de la matriz STFT

    %Normalizacion [-1,1]
    [data_mag, norm_mag_settings]= mapminmax(data_mag');
    data_mag = data_mag';
    [data_phase, norm_phase_settings]= mapminmax(data_phase');
    data_phase = data_phase';
    
    feature_vectors = [];
    recorrido_filas = floor(filas/frames_package)*frames_package - frames_package*filas_raw;        %total de filas a recorrer
    p = 1;                                                                                          %variable recorrido columnas
    for j=1:filas_raw:recorrido_filas                                                               %Loop archivo filas
        if j >= recorrido_filas
            break
        else
                feature_vector_mag = data_mag(j:j+frames_package*filas_raw-1, 1);               %Extraigo 6 columnas m?dulo
                feature_vector_phase = data_phase(j:j+frames_package*filas_raw-1, 1);           %Extraigo 6 columnas fase
                feature_vectors(:,p) = [feature_vector_mag ; feature_vector_phase];             %Conformo el vector columna feature vector(M1-M5:F1:5, etc)
                p = p+1;
        end
          
    end
    
    output = strcat(directorio_salida, '/', archivo);                %nombre archivo anecoico
    save(output,'feature_vectors','norm_mag_settings','norm_phase_settings');   
    
end
