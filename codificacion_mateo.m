% Paso 2: Codificación PCM y DPCM
clear; clc;

% Cargar el archivo raw
load('raw_signal_mateo.mat');  

% Definir la frecuencia de muestreo (Hz)
Fs = 44100;  % Frecuencia de muestreo (44.1 kHz)

% Parámetros de PCM
bits_values = [8, 12, 16]; % Bits para PCM

% Inicialización de la tabla de resultados
bit_rate_table = table(); 
snr_values = [];

% Codificación PCM para diferentes profundidades de bits
for i = 1:length(bits_values)
    % Codificación PCM
    bits = bits_values(i);
    max_val = 2^(bits - 1) - 1;  % Máximo valor para la cantidad de bits seleccionados
    pcm_signal = round(signal * max_val);  % Cuantización de la señal PCM
    pcm_signal = pcm_signal / max_val;  % Normalización al rango -1 a 1

    % Cálculo de SNR (relación señal/ruido) antes y después de la codificación PCM
    noise = pcm_signal - signal; % Diferencia entre la señal original y la señal codificada
    
    % Evitar valores muy pequeños en el ruido (para no obtener Inf)
    if norm(noise) < 1e-10
        snr = 1000; % Establecer un valor grande para el SNR si el ruido es muy bajo
    else
        snr = 20 * log10(norm(signal) / norm(noise)); % Cálculo de SNR en dB
    end
    
    snr_values = [snr_values; snr];
    
    % Agregar a la tabla de resultados
    bit_rate_table = [bit_rate_table; table(bits, snr)];
end

% Guardar una sola imagen para la señal original y la PCM
figure;
subplot(2, 1, 1);
plot(signal, 'b', 'LineWidth', 2);  % Señal original en azul con línea gruesa
title('Señal Original');
xlabel('Muestras');
ylabel('Amplitud');
grid on;

subplot(2, 1, 2);
plot(pcm_signal, 'r--', 'LineWidth', 1.5);  % Señal PCM en rojo punteada
title(['Señal PCM con ', num2str(bits_values(1)), ' bits']);
xlabel('Muestras');
ylabel('Amplitud');
grid on;

% Guardar esta figura como la imagen de la señal original y PCM
saveas(gcf, 'grafica_signales_comparativa.png');

% Guardar una sola imagen para los espectros de frecuencia
figure;
N = length(signal);
f = (0:N-1) * (Fs/N);
Y_original = abs(fft(signal));
Y_pcm = abs(fft(pcm_signal));

subplot(2, 1, 1);
plot(f(1:N/2), Y_original(1:N/2));
title('Espectro de Frecuencia - Señal Original');
xlabel('Frecuencia [Hz]');
ylabel('Magnitud');
grid on;

subplot(2, 1, 2);
plot(f(1:N/2), Y_pcm(1:N/2));
title('Espectro de Frecuencia - PCM');
xlabel('Frecuencia [Hz]');
ylabel('Magnitud');
grid on;

% Guardar esta figura como la imagen de espectros
saveas(gcf, 'grafica_spectros_comparativa.png');

% Guardar la imagen de SNR vs Bit-rate
figure;
plot(bits_values, snr_values, '-o');
title('Relación entre Bit-rate y SNR');
xlabel('Número de Bits');
ylabel('SNR (dB)');
grid on;

% Guardar esta figura como la imagen de SNR vs Bit-rate
saveas(gcf, 'grafica_snr_vs_bit_rate.png');

% Mostrar la tabla con los resultados de SNR y bit-rate
disp('Tabla de Bit-rate y SNR:');
disp(bit_rate_table);
