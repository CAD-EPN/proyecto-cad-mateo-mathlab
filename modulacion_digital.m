% Paso 5: Modulación digital (ASK, 2-FSK, 16-QAM) con señales previas

clear; clc;

% Cargar la señal raw
load('raw_signal_mateo.mat');

% Parámetros
Fs = 44100;  % Frecuencia de muestreo (44.1 kHz)
EbNo_dB = 0:2:10; % Rango de SNR (Eb/No) en dB
num_bits = length(signal); % Número de bits (igual a la longitud de la señal procesada)

% Generar una secuencia aleatoria de bits
bits = randi([0, 1], num_bits, 1);

% Modulación ASK (Amplitude Shift Keying)
M_ASK = 2; % M = 2 para ASK (dos símbolos: 0 y 1)
symbols_ASK = 2*bits - 1;  % Mapear 0->-1 y 1->1 (ASK)

% Modulación 2-FSK (Frequency Shift Keying)
M_FSK = 2; % M = 2 para 2-FSK
f1 = 1000; % Frecuencia para el bit 0
f2 = 2000; % Frecuencia para el bit 1
t = (0:num_bits-1) / Fs; % Tiempo
symbols_FSK = zeros(1, num_bits);

% Mapear bits a frecuencias
for i = 1:num_bits
    if bits(i) == 0
        symbols_FSK(i) = sin(2*pi*f1*t(i));  % Bit 0
    else
        symbols_FSK(i) = sin(2*pi*f2*t(i));  % Bit 1
    end
end

% Modulación 16-QAM (16-Quadrature Amplitude Modulation)
M_QAM = 16; % M = 16 para 16-QAM
symbols_QAM = qammod(bits, M_QAM);

% Curvas BER vs Eb/No
% Inicializamos las variables para las curvas BER
BER_ASK = zeros(length(EbNo_dB), 1);
BER_FSK = zeros(length(EbNo_dB), 1);
BER_QAM = zeros(length(EbNo_dB), 1);

% Simulación de errores por cada valor de Eb/No
for i = 1:length(EbNo_dB)
    % AWGN noise for each modulation type
    snr = EbNo_dB(i);
    
    % Modulación ASK (transmitir señales con ruido)
    received_ASK = awgn(symbols_ASK, snr, 'measured');
    decoded_ASK = real(received_ASK) > 0;  % Decodificación por comparación con 0
    BER_ASK(i) = sum(bits ~= decoded_ASK) / num_bits;  % Calcular BER
    
    % Modulación 2-FSK (transmitir señales con ruido)
    received_FSK = awgn(symbols_FSK, snr, 'measured');
    % Decodificación por comparación de frecuencias
    decoded_FSK = zeros(size(bits)); % reiniciar el vector de decodificación
    for j = 1:num_bits
        if abs(received_FSK(j)) == sin(2*pi*f1*t(j))
            decoded_FSK(j) = 0;
        else
            decoded_FSK(j) = 1;
        end
    end
    BER_FSK(i) = sum(bits ~= decoded_FSK) / num_bits;  % Calcular BER
    
    % Modulación 16-QAM (transmitir señales con ruido)
    received_QAM = awgn(symbols_QAM, snr, 'measured');
    decoded_QAM = qamdemod(received_QAM, M_QAM);  % Decodificación 16-QAM
    BER_QAM(i) = sum(bits ~= decoded_QAM) / num_bits;  % Calcular BER
end

% Graficar las curvas BER vs Eb/No en una sola figura y guardar directamente
figure; % Abrir figura para plotear
plot(EbNo_dB, BER_ASK, '-o', 'LineWidth', 2, 'MarkerSize', 6, 'Color', 'b'); hold on;
plot(EbNo_dB, BER_FSK, '-x', 'LineWidth', 2, 'MarkerSize', 6, 'Color', 'r');
plot(EbNo_dB, BER_QAM, '-s', 'LineWidth', 2, 'MarkerSize', 6, 'Color', 'g');
xlabel('Eb/No (dB)');
ylabel('Tasa de Error de Bit (BER)');
title('Curvas BER vs Eb/No para diferentes modulaciones');
legend('ASK', '2-FSK', '16-QAM');
grid on;
saveas(gcf, 'curvas_ber_vs_EbNo.png');  % Guardar la gráfica en un archivo

% Graficar las constelaciones de cada modulación en gráficos separados y guardar directamente

% Constelación ASK
figure; % Abrir nueva figura para ASK
plot(symbols_ASK, 'o', 'MarkerSize', 8, 'Color', 'b');
title('Constelación ASK');
xlabel('I (In-phase)');
ylabel('Q (Quadrature)');
grid on
saveas(gcf, 'constelacion_ASK.png');  % Guardar la figura de ASK

% Constelación 2-FSK
figure; % Abrir nueva figura para 2-FSK
plot(t, symbols_FSK, 'r', 'LineWidth', 1);
title('Señal 2-FSK');
xlabel('Tiempo (s)');
ylabel('Amplitud');
grid on
saveas(gcf, 'constelacion_2_FSK.png');  % Guardar la figura de 2-FSK

% Constelación 16-QAM
figure; % Abrir nueva figura para 16-QAM
plot(real(symbols_QAM), imag(symbols_QAM), 'gs', 'MarkerSize', 6);
title('Constelación 16-QAM');
xlabel('I (In-phase)');
ylabel('Q (Quadrature)');
grid on
saveas(gcf, 'constelacion_16_QAM.png');  % Guardar la figura de 16-QAM

disp('Gráficas generadas y guardadas en los archivos correspondientes.');
