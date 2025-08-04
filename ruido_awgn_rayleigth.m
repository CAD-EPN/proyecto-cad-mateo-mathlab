% Paso 4: Canal ruidoso - AWGN y Rayleigh
clear; clc;

% Cargar el archivo raw
load('raw_signal_mateo.mat'); 

% Definir la frecuencia de muestreo (Hz)
Fs = 44100;  % Frecuencia de muestreo (44.1 kHz)

% Parámetros del canal
SNR_AWGN = 10;  % Relación señal-ruido para AWGN (dB)
K_rayleigh = 3; % Factor de desvanecimiento Rayleigh (K=3)

% 1. Simulación de AWGN (ruido blanco aditivo gaussiano)
awgn_signal = awgn(signal, SNR_AWGN, 'measured'); % Añadir AWGN a la señal

% 2. Simulación de desvanecimiento Rayleigh
rayleigh_fading = (randn(size(signal)) + 1i*randn(size(signal))) / sqrt(2);  % Canal de Rayleigh
rayleigh_signal = real(rayleigh_fading) .* signal;  % Señal afectada por Rayleigh

% Graficar las señales en una sola figura con tres subgráficas
figure;

% Subgráfico 1: Señal Original
subplot(3, 1, 1);
plot(signal, 'b', 'LineWidth', 2);  % Señal original en azul con línea gruesa
title('Señal Original');
xlabel('Muestras');
ylabel('Amplitud');
grid on;

% Subgráfico 2: Señal con AWGN
subplot(3, 1, 2);
plot(awgn_signal, 'r--', 'LineWidth', 1.5);  % Señal con AWGN en rojo (línea punteada)
title(['Señal con AWGN (SNR = ', num2str(SNR_AWGN), ' dB)']);
xlabel('Muestras');
ylabel('Amplitud');
grid on;

% Subgráfico 3: Señal con Rayleigh
subplot(3, 1, 3);
plot(rayleigh_signal, 'g:', 'LineWidth', 1.5);  % Señal con Rayleigh en verde (línea punteada)
title(['Señal con Desvanecimiento Rayleigh (K = ', num2str(K_rayleigh), ')']);
xlabel('Muestras');
ylabel('Amplitud');
grid on;

% Guardar la figura completa como una única imagen
saveas(gcf, 'grafica_comparativa_unica.png');  % Guardar la gráfica comparativa en un solo archivo

% Calcular SNR después del ruido
snr_awgn = 20 * log10(norm(signal) / norm(signal - awgn_signal));
snr_rayleigh = 20 * log10(norm(signal) / norm(signal - rayleigh_signal));

% Mostrar los resultados
disp(['SNR después de AWGN: ', num2str(snr_awgn), ' dB']);
disp(['SNR después de Rayleigh: ', num2str(snr_rayleigh), ' dB']);
