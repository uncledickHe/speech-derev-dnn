% [FileName,PathName] = uigetfile('*.wav', 'Seleccione los archivos anecoicos', 'MultiSelect', 'on' );

dir_anecoico = uigetdir('/Volumes/Material/Eze/Dropbox/Tesis-Ezequiel/00-Audios/', 'Seleccione los archivos anecoicos');
files_anecoico= dir(fullfile(dir_anecoico, '*.wav'));   %nombres de los archivos anecoicos

dir_ir = uigetdir('/Volumes/Material/Eze/Dropbox/Tesis-Ezequiel/00-Audios/', 'Seleccione los archivos de Rta al impulso');
files_ir = dir(fullfile(dir_ir, '*.wav'));              %nombres de los archivos ir

output_dir = '/Volumes/Material/Eze/Dropbox/Tesis-Ezequiel/00-Audios/output';

m = length(files_anecoico);         %cantidad de archivos anecoicos
n = length(files_ir);               %cantidad de archivos anecoicos
fs = 16000;                         %Sampling rate de salida

tic
for i=1:m
    nombre_anecoico = strcat(dir_anecoico, '/', files_anecoico(i).name);
    anecoica = audioread(nombre_anecoico);                                  %Leo archivo anecoico
    
    for j=1:n
            nombre_ir = strcat(dir_ir, '/', files_ir(j).name);              %nombre del archivo ir
            ir = audioread(nombre_ir);                                      %Leo archivo ir
            convolucion = conv(ir, anecoica);                               %convolucion entre anecoico y rir
            maxi = max(abs(convolucion));                                   %m?ximo de la conv
            convolucion = convolucion .* (0.9)/maxi;                        %normalizacion de la conv
            nombre_anecoico_sinwav = strrep(files_anecoico(i).name, '.wav', '');    
            output_dir_name = strcat(output_dir,'/',nombre_anecoico_sinwav,'-', files_ir(j).name);
            audiowrite(output_dir_name, convolucion, fs);
    end
    
end
toc