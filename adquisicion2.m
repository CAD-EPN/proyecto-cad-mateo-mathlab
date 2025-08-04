% Adquisición y procesamiento de archivo WAV
% Parámetros:
% Frecuencia de muestreo = 44.1 kHz, 16 bits, mono (ajustar si es necesario)

clear; clc; close all;

% Parámetros
filename = 'mateo.wav'; % Nombre del archivo WAV
Fs = 44100;            % Frecuencia de muestreo (44.1 kHz)

% Leer el archivo WAV
[signal, ~] = audioread(filename);  % Lee el archivo WAV y la señal

% Verificar si la señal fue leída correctamente
if isempty(signal)
    error('El archivo WAV está vacío o no se pudo leer correctamente.');
end

% Reproducir la señal cargada
disp('Reproduciendo la señal cargada...');
soundsc(signal, Fs); % Reproduce el archivo WAV

% Normalizar la señal para evitar recorte
max_val = max(abs(signal));   % Obtener el valor máximo absoluto de la señal
if max_val > 0
    signal = signal / max_val; % Normalizar la señal al rango -1 a 1
end

% Duración de la señal
duration = length(signal) / Fs;  % Duración en segundos

disp(['Duración del audio procesado: ', num2str(duration), ' segundos']);
disp(['Valor máximo de la señal: ', num2str(max(abs(signal)))]);  % Verificar la amplitud de la señal

% Gráfica en el dominio del tiempo
figure;  % Asegurarse de crear una nueva figura
t = (0:length(signal)-1) / Fs;
plot(t, signal);
xlabel('Tiempo [s]');
ylabel('Amplitud');
title('Señal en el Tiempo');
grid on;
drawnow;  % Asegura que la figura se dibuje

% Guardar la gráfica en un archivo
saveas(gcf, 'grafica_tiempo_mateo.png');

% Gráfica en el dominio de la frecuencia (FFT)
figure;  % Crear una nueva figura para el espectro
N = length(signal);
f = (0:N-1) * (Fs/N);
Y = abs(fft(signal));

plot(f(1:N/2), Y(1:N/2)); % Solo la mitad del espectro
xlabel('Frecuencia [Hz]');
ylabel('Magnitud');
title('Espectro de Frecuencia (FFT)');
grid on;
drawnow;  % Asegura que la figura se dibuje

% Guardar la gráfica en un archivo
saveas(gcf, 'grafica_frecuencia_mateo.png');

% Guardar la señal procesada en un archivo .mat (raw_signal.mat)
save('raw_signal_mateo.mat', 'signal');

disp('Señal procesada, gráficas generadas y archivo RAW guardado.');
