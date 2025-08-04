% Paso 7: Demodulacion
clear;
clc;

% Cargar la señal desde 'raw
load('raw_signal_mateo.mat');  % Asegúrate de que la ruta es correcta

% Verificar la variable cargada
whos;

% Suponemos que la variable en 'raw_signal_jeff.mat' se llama 'signal'
% Si tiene otro nombre, reemplázalo con el nombre correcto
signal_data = signal;  % Reemplaza con el nombre correcto si es diferente

% Mostrar tamaño de la señal cargada
disp(['Tamaño de la señal cargada: ', num2str(length(signal_data))]);

% Normalizar la señal para convertirla en un rango adecuado para la modulación
normalized_signal = (signal_data - min(signal_data)) / (max(signal_data) - min(signal_data));

% Modulación 16-QAM (Quadrature Amplitude Modulation)
M = 16;    % Usamos 16-QAM
mod_signal = qammod(floor(normalized_signal * (M-1)), M);  % Mapear a valores de 0 a M-1

% Agregar ruido blanco aditivo (AWGN)
SNR = 20; % Relación señal-ruido en dB
signal_noisy = awgn(mod_signal, SNR, 'measured');  % Señal ruidosa

% Demodulación 16-QAM
demod_signal = qamdemod(signal_noisy, M);  % Demodulación

% Reconstrucción de la señal a partir de los valores demodulados
reconstructed_signal = demod_signal / (M-1);  % Normalizar nuevamente

% Escalar la señal reconstruida a los valores de amplitud originales
reconstructed_signal = reconstructed_signal * (max(signal_data) - min(signal_data)) + min(signal_data);

% Asegurarnos de que la señal reconstruida tenga la misma longitud que la señal original
reconstructed_signal = reconstructed_signal(1:length(signal_data));

% Recortar la señal reconstruida a un rango permitido [-1, 1] para evitar clipping
reconstructed_signal = max(min(reconstructed_signal, 1), -1);

% Guardar la señal reconstruida como un archivo de audio
audiowrite('reconstructed_signal_from_mat.wav', reconstructed_signal, 44100);  % Guardar la señal reconstruida

% Reproducir la señal original (raw_signal_jeff)
disp('Reproduciendo la señal original...');
sound(signal_data, 44100);  % Reproducir la señal original
pause(length(signal_data) / 44100);  % Pausar hasta que termine la reproducción

% Reproducir la señal reconstruida
disp('Reproduciendo la señal reconstruida...');
sound(reconstructed_signal, 44100);  % Reproducir la señal reconstruida

% Cálculo del SNR entre la señal original y la reconstruida
signal_power = mean(abs(signal_data).^2);
noise_power = mean(abs(reconstructed_signal - signal_data).^2);
SNR_calculated = 10 * log10(signal_power / noise_power);

% Mostrar SNR calculado
disp(['SNR Calculado: ', num2str(SNR_calculated), ' dB']);

% Guardar la métrica SNR en un archivo
fid = fopen('metrics_from_mat.txt', 'w');
fprintf(fid, 'SNR Calculado: %.2f dB\n', SNR_calculated);
fclose(fid);

% Graficar la señal original y la reconstruida
figure;

subplot(2,1,1);
plot(signal_data);
title('Señal Original (raw_signal_mateo.mat)');
xlabel('Muestras');
ylabel('Amplitud');

subplot(2,1,2);
plot(reconstructed_signal);
title('Señal Reconstruida');
xlabel('Muestras');
ylabel('Amplitud');

% Guardar el gráfico en un archivo
saveas(gcf, 'signal_reconstruction_from_mat_plot.png');
