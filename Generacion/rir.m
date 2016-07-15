c = 343;                            % Sound velocity (m/s)
fs = 16000;                         % Sample frequency (samples/s)
r = [3.8 2.5 1.7 ; 5 5.3 1.75];     % Receiver positions [x_1 y_1 z_1 ; x_2 y_2 z_2] (m)
s = [8 3.1 1.8];                    % Source position [x y z] (m)
L = [10 7 3];                       % Room dimensions [x y z] (m)
beta = 0.9;                         % Reverberation time (s)
n = pow2(nextpow2(fs*0.9));         % Number of samples power of 2
ndiff = n - fs*0.9;                 % Samples usados para zero padding
mtype = 'omnidirectional';          % Type of microphone
order = -1;                         % -1 equals maximum reflection order!
dim = 3;                            % Room dimension
orientation = [0 0];                % Microphone orientation (rad)
hp_filter = 1;                      % Enable high-pass filter

h = rir_generator(c, fs, r, s, L, beta, n, mtype, order, dim, orientation, hp_filter);

%separacion de rirs
rir1 = (h(1,:));
rir2 = (h(2,:));

%filenames
nombre1 = strcat('rir-',num2str(beta),'-r1','.wav');
nombre2 = strcat('rir-',num2str(beta),'-r2','.wav');

%export
audiowrite(nombre1, rir1, fs)
audiowrite(nombre2, rir2, fs)
