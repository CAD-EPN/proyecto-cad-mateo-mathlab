clear; clc; close all;

% Paso 1: Adquisición de la señal (audio .wav)
Fs = 44100;  % Frecuencia de muestreo
filename = 'mateo.wav';  % Nombre del archivo WAV
[signal, ~] = audioread(filename);  % Leer el archivo de audio

if isempty(signal)
    error('El archivo WAV está vacío o no se pudo leer correctamente.');
end

% Normalizar la señal para que esté en el rango [-1, 1]
signal = signal / max(abs(signal));

% Guardar la señal original como 'raw_signal_mateo.mat'
save('raw_signal_mateo.mat', 'signal');

% Reproducir la señal cargada para verificación
disp('Reproduciendo la señal cargada...');
soundsc(signal, Fs);
pause(length(signal) / Fs);  % Pausar hasta que termine la reproducción

% Gráfico de la señal en el dominio del tiempo (Adquisición)
figure;
t = (0:length(signal)-1) / Fs;
subplot(2, 1, 1);
plot(t, signal);
xlabel('Tiempo [s]');
ylabel('Amplitud');
title('Señal en el Tiempo (Adquisición)');
grid on;

% Gráfica de la señal en frecuencia (FFT)
N = length(signal);
f = (-N/2:N/2-1)*(Fs/N);  % Eje de frecuencia
signal_fft = fftshift(fft(signal));  % FFT y desplazamiento de cero

subplot(2, 1, 2);
plot(f, abs(signal_fft));
xlabel('Frecuencia [Hz]');
ylabel('Amplitud');
title('Espectro de Frecuencia');
grid on;
saveas(gcf, 'grafica_tiempo_frecuencia.png');

% Cargar la señal desde el archivo .mat (raw_signal_mateo.mat)
load('raw_signal_mateo.mat');  % Cargar la señal guardada en raw_signal_mateo.mat

% Paso 2: Codificación PCM y DPCM
bits_values = [8, 12, 16];
snr_values = zeros(length(bits_values), 1);
bit_rate_table = table('Size', [length(bits_values), 2], 'VariableTypes', {'double', 'double'}, 'VariableNames', {'Bits', 'SNR'});

for i = 1:length(bits_values)
    bits = bits_values(i);
    max_val = 2^(bits - 1) - 1;
    pcm_signal = round(signal * max_val) / max_val;  % Cuantización PCM
    pcm_signal = pcm_signal / max_val;  % Normalización PCM
    
    % Calcular SNR
    noise = pcm_signal - signal;
    if norm(noise) ~= 0
        snr = 20 * log10(norm(signal) / norm(noise));  % Si el ruido no es cero, calculamos SNR
    else
        snr = 1000;  % En caso de que el ruido sea casi cero, asignamos un valor alto a SNR
    end
    snr_values(i) = snr;  % Guardar el valor de SNR
    
    % Agregar a la tabla de resultados
    bit_rate_table(i, :) = {bits, snr};
end

% Gráfico comparativo señal original vs PCM (Codificación)
figure;
subplot(2, 1, 1);
plot(signal, 'b');
title('Señal Original');
subplot(2, 1, 2);
plot(pcm_signal, 'r--');
title(['Señal PCM con ', num2str(bits_values(1)), ' bits']);
saveas(gcf, 'grafica_codificacion.png');

% Tabla bit-rate vs SNR
disp('Tabla bit-rate vs SNR:');
disp(bit_rate_table);

% Paso 5: Modulación 16-QAM
M = 16;  % Usamos 16-QAM (M=16)
normalized_signal = (signal - min(signal)) / (max(signal) - min(signal));  % Normalizar

% Convertir la señal normalizada a valores enteros para la modulación
symbols = floor(normalized_signal * (M - 1));  % Mapear la señal a los valores enteros de 0 a M-1

% Modulación QAM (16-QAM)
mod_signal = qammod(symbols, M);  % Modulación QAM

% Graficar la constelación de la modulación (Modulación)
figure;
scatter(real(mod_signal), imag(mod_signal), 'o');
title('Constelación 16-QAM');
xlabel('I (In-phase)');
ylabel('Q (Quadrature)');
grid on;
saveas(gcf, 'grafica_constelacion_qam.png');

% Paso 7: Demodulación y reconstrucción de la señal
demod_signal = qamdemod(mod_signal, M);  % Demodulación QAM

% Reconstrucción de la señal: Es necesario desnormalizar
reconstructed_signal = (demod_signal / (M - 1));  % Desnormalizar

% Asegurarse de que la señal reconstruida tenga la misma longitud que la original
reconstructed_signal = reconstructed_signal(1:length(signal));

% Recortar la señal reconstruida a un rango permitido [-1, 1] para evitar clipping
reconstructed_signal = max(min(reconstructed_signal, 1), -1);

% Graficar la señal original y la reconstruida (Demodulación)
figure;
subplot(2, 1, 1);
plot(signal);
title('Señal Original');
subplot(2, 1, 2);
plot(reconstructed_signal);
title('Señal Reconstruida');
saveas(gcf, 'signal_reconstruction_from_mat_plot.png');

% Calcular y mostrar SNR
signal_power = mean(abs(signal).^2);
noise_power = mean(abs(reconstructed_signal - signal).^2);
SNR_calculated = 10 * log10(signal_power / noise_power);
disp(['SNR Calculado: ', num2str(SNR_calculated), ' dB']);

% Guardar el SNR calculado en un archivo de texto
fileID = fopen('metrics_from_mat.txt', 'w');  % Abrir el archivo para escribir
fprintf(fileID, 'SNR Calculado: %.2f dB\n', SNR_calculated);  % Escribir el valor de SNR
fclose(fileID);  % Cerrar el archivo

% Reproducir la señal decodificada
disp('Reproduciendo la señal reconstruida...');
soundsc(reconstructed_signal, Fs);  % Reproducir la señal reconstruida

% Gráfico de la Razón de Compresión y MSE
compression_ratio = length(signal) / length(pcm_signal);  % Razón de compresión
MSE = mean((signal - reconstructed_signal).^2);  % Error Cuadrático Medio

figure;
subplot(2, 1, 1);
bar(compression_ratio);
ylabel('Razón de Compresión');
title('Razón de Compresión');
subplot(2, 1, 2);
bar(MSE);
ylabel('MSE');
title('Error Cuadrático Medio (MSE)');
saveas(gcf, 'grafica_compression_mse.png');

% Funciones auxiliares
function mod_signal = qammod(bits, M)
    % Modulación QAM
    mod_signal = (2 * bits) - (M - 1);  % QAM sin necesidad de bi2de
end

function demod_signal = qamdemod(mod_signal, M)
    % Demodulación QAM
    demod_signal = mod_signal;  % Simplificado para este ejemplo
end
