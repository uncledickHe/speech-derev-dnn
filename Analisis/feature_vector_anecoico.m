clearvars
clc

directorio= uigetdir('/Volumes/Boot/00Files-tesis', 'Seleccione los archivos a analizar');
files= dir(fullfile(directorio, '*.mat'));                          %nombres de los archivos
directorio_salida = uigetdir('/Volumes/Boot/00Files-tesis', 'Seleccione el directorio de salida para los feature vectors');
%directorio_anecoicos_length = uigetdir('/Volumes/Boot/00Files-tesis', 'Seleccione el directorio de salida para anecoicos_length');

cant_archivos = length(files);                                      %cantidad de archivos
anecoicos_length = cell(cant_archivos,2);                           %Variable para almacenar los tama?os de cada STFT anecoico


for ii=1:cant_archivos                                              %Loop de archivos
    archivo = files(ii).name;                                       %nombre archivo .mat
    data = load(strcat(directorio,'/',archivo),'transformada');                     %Carga del contenido del .mat
    data = data.transformada;                                       %Carga del contenido del .mat

    data_mag = abs(data);                                           %Magnitud de la STFT
    data_phase = angle(data);                                       %Fase de la STFT
    [filas, columnas] = size(data_mag);                             %Tamano de la matriz de mag o fase en columna del stack
    
    %Normalizacion [0,1]
    [data_mag, norm_mag_settings]= mapminmax(data_mag',0,1);            
    data_mag = data_mag';
    [data_phase, norm_phase_settings]= mapminmax(data_phase',0,1);
    data_phase = data_phase';
    %Cantidad de columnas de cada archivo
    
    anecoicos_length(ii,:) = [cellstr(strrep(archivo,'.mat','')) num2str(columnas)];
    
    feature_vectors_out = zeros(2*filas,columnas);
    
    for j=1:columnas                                           %
            feature_vectors_out(:,j) = [data_mag(:,j) ; data_phase(:,j)];
    end

    
    save(strcat(directorio_salida, '/', archivo),'feature_vectors_out');                                    %Save feature_vector_anecoico
    
    if ii == cant_archivos
        save(strcat(directorio_salida, '/','anecoicos_length'),'anecoicos_length');                         %Save anecoicos_length
    end
    
end
