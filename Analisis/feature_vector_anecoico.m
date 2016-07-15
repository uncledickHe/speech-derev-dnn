clear all
clc

directorio= uigetdir('/Volumes/Boot/00Files-tesis', 'Seleccione los archivos a analizar');
files= dir(fullfile(directorio, '*.mat'));   %nombres de los archivos
directorio_salida= uigetdir('/Volumes/Boot/00Files-tesis', 'Seleccione el directorio de salida');

cant_archivos = length(files);                  %cantidad de archivos

for ii=1:cant_archivos                                              %Loop de archivos
    archivo = files(ii).name;                                       %nombre archivo .mat
    data = load(strcat(directorio,'/',archivo),'transformada');                     %Carga del contenido del .mat
    data = data.transformada;                                       %Carga del contenido del .mat

    data_mag = abs(data);                                           %Magnitud de la STFT
    data_phase = angle(data);                                       %Fase de la STFT
    [filas, columnas] = size(data_mag);                                 %Tamano de la matriz de mag o fase en columna del stack

    feature_vectors_out = zeros(2*filas,columnas);
    for j=1:columnas                                           %
            feature_vectors_out(:,j) = [data_mag(:,j) ; data_phase(:,j)];
    end
    
    output = strcat(directorio_salida, '/', archivo);                %nombre archivo anecoico
    save(output,'feature_vectors_out');   
    
end
