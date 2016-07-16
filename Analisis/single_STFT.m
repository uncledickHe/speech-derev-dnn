clearvars
clc

directorio= uigetdir('/Volumes/Material/Eze/Drive/Tesis-Ezequiel/00-Audios', 'Seleccione los archivos a analizar');
files= dir(fullfile(directorio, '*.wav'));   %nombres de los archivos
directorio_salida= uigetdir('/Volumes/Boot/00Files-tesis', 'Seleccione el directorio de salida');

m = length(files);          %cantidad de archivos anecoicos
fs = 16e3;                  %sampling rate

w = 20e-3;                  %window size in msec
wlen = w*fs;                %samples x ventana
wlen = pow2(nextpow2(wlen));%siguiente valor potencia de 2 -->512

h = 10e-3;                  %hop size in msec
hlen = h*fs;                %hop size in samples
hlen = pow2(nextpow2(hlen));%siguiente valor potencia de 2 -->256

nfft = 512;                 %fft bins
%nfft = pow2(nextpow2(nfft));%siguiente valor potencia de 2

%K = sum(hamming(wlen, 'periodic'))/wlen;

for ii=1:m 
    nombre = strcat(directorio, '/', files(ii).name);               %nombre archivo anecoico
    x = audioread(nombre);                                          
    [transformada, f, t] = stft(x, wlen, hlen, nfft, fs);           %STFT
%   transformada = transformada/wlen/K;                
    if rem(nfft, 2)                                                 %odd nfft excludes Nyquist point
        transformada(2:end, :) = transformada(2:end, :).*2;
    else                                                            %even nfft includes Nyquist point
        transformada(2:end-1, :) = transformada(2:end-1, :).*2;
    end
    
    nombre = strrep(files(ii).name,'.wav','');
    output = strcat(directorio_salida,'/', nombre, '.mat');          %output directory
    save(output,'transformada','t','f')
end
