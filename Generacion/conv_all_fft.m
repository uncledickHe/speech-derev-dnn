% [FileName,PathName] = uigetfile('*.wav', 'Seleccione los archivos anecoicos', 'MultiSelect', 'on' );

dir_anecoico = uigetdir('/Volumes/Material/Eze/Drive/Tesis-Ezequiel/00-Audios/anechoic/', 'Seleccione los archivos anecoicos');
files_anecoico= dir(fullfile(dir_anecoico, '*.wav'));   %nombres de los archivos anecoicos

dir_ir = uigetdir('/Volumes/Material/Eze/Drive/Tesis-Ezequiel/00-Audios/IR/', 'Seleccione los archivos de Rta al impulso');
files_ir = dir(fullfile(dir_ir, '*.wav'));              %nombres de los archivos ir

output_dir = '/Volumes/Material/Eze/Drive/Tesis-Ezequiel/00-Audios/output';

m = length(files_anecoico);         %cantidad de archivos anecoicos
n = length(files_ir);               %cantidad de archivos anecoicos
fs = 16000;                         %Sampling rate de salida

tic
for i=1:m
    nombre_anecoico = strcat(dir_anecoico, '/', files_anecoico(i).name);    %%nombre archivo anecoico
    anecoica = audioread(nombre_anecoico);                                  %Leo archivo anecoico
    
    for j=1:n
            nombre_ir = strcat(dir_ir, '/', files_ir(j).name);              %nombre archivo ir
            ir = audioread(nombre_ir);                                      %Leo archivo ir
            %{
            L = length(ir) + length(anecoica) - 1
            convolucion = cconv(ir, anecoica, L)
            cconv es equivalente al padding y fft que hago en las siguientes lineas
            %}
            irpad = [ir;zeros(length(anecoica)-1,1)];                           %pad hasta llegar a ir+anecoico-1
            anecoicapad = [anecoica; zeros(length(ir)-1,1)];                    %pad hasta llegar a ir+anecoico-1
            convolucion = ifft(fft(irpad).*fft(anecoicapad));
            maxi = max(abs(convolucion));                                       %maximo de la conv
            convolucion = convolucion .* (0.9)/maxi;                            %normalizacion de la conv
            nombre_anecoico_sinwav = strrep(files_anecoico(i).name, '.wav', '');    
            output_dir_name = strcat(output_dir,'/',nombre_anecoico_sinwav,'-', files_ir(j).name);
            audiowrite(output_dir_name, convolucion, fs);
    end
    
end
toc