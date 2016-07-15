clear all
clc

directorio= uigetdir('/Volumes/Boot/00Files-tesis', 'Seleccione los archivos a analizar');
files= dir(fullfile(directorio, '*.mat'));   %nombres de los archivos
directorio_salida= uigetdir('/Volumes/Boot/00Files-tesis', 'Seleccione el directorio de salida');

cant_archivos = length(files);                  %cantidad de archivos
frames_package = 6;                        !     %cuantos frames vecinos entran en el feature vector

for ii=1:cant_archivos                                              %Loop de archivos
    archivo = files(ii).name;                                       %nombre archivo .mat
    data = load(strcat(directorio,'/',archivo),'transformada');                     %Carga del contenido del .mat
    data = data.transformada;                                       %Carga del contenido del .mat

    data_mag_raw = abs(data);                                           %Magnitud de la STFT
    data_mag = data_mag_raw(:);                                         %Vector columna de la magnitud
    data_phase_raw = angle(data);                                       %Fase de la STFT
    data_phase = data_phase_raw(:);                                     %Vector columna de la fase
    [filas, columnas] = size(data_mag);                                 %Tamano de la matriz de mag o fase en columna del stack
    [filas_raw, columnas_raw] = size(data_mag_raw);                     %Tamano de la matriz de mag o fase en columna de la matriz STFT

    feature_vectors = [];
    recorrido_filas = floor(filas/frames_package)*frames_package - frames_package*filas_raw;                   %total de filas a recorrer
    p = 1;                                                                                  %recorrido columnas
    for j=1:filas_raw:recorrido_filas                                           %
        if j >= recorrido_filas
            break
        else
                feature_vector_mag = data_mag(j:j+frames_package*filas_raw-1, 1);            %Extraigo 6 columnas
                feature_vector_phase = data_phase(j:j+frames_package*filas_raw-1, 1);
                feature_vectors(:,p) = [feature_vector_mag ; feature_vector_phase];
                p = p+1;
        end
          
    end
    
    output = strcat(directorio_salida, '/', archivo);                %nombre archivo anecoico
    save(output,'feature_vectors');   
    
end
