%Paso 6: OFDM con 64 subportadoras

clear; clc;

% Cargar la señal procesada desde el Paso 1 hasta el Paso 4
disp('Cargando señal...');
load('raw_signal_mateo.mat');  % Cambiar según sea 'raw_signal_mateo.mat' para Mateo

% Parámetros generales
Fs = 44100;  % Frecuencia de muestreo (44.1 kHz)
N = 64; % Número de subportadoras
prefix_length = 16; % Longitud del prefijo cíclico
num_bits = length(signal); % Número de bits por subportadora
modulation_types = {'QPSK', '16-QAM'}; % Tipos de modulación

% Generar bits aleatorios para las subportadoras
disp('Generando bits aleatorios...');
bits = randi([0, 1], N * num_bits, 1);

% Asegurar que la longitud de la señal sea un múltiplo de N (64 subportadoras)
num_samples = length(signal);
num_samples_to_keep = floor(num_samples / N) * N;  % Recortar para que sea múltiplo de N
signal = signal(1:num_samples_to_keep);  % Recortar la señal

disp('Realizando modulación...');
% Modulación (QPSK y 16-QAM)
mod_QPSK = qpsk_mod(bits);
mod_16QAM = qam_mod(bits, 16);

disp('Transmisión OFDM...');
% OFDM Transmitir y agregar prefijo cíclico
ofdm_signal_QPSK = ofdm_transmit(mod_QPSK, N, prefix_length);
ofdm_signal_16QAM = ofdm_transmit(mod_16QAM, N, prefix_length);

% Calcular y graficar PSD (Densidad Espectral de Potencia)
disp('Calculando PSD...');
figure;
psd_QPSK = psd(ofdm_signal_QPSK, Fs);
psd_16QAM = psd(ofdm_signal_16QAM, Fs);
plot(psd_QPSK.Frequencies, 10*log10(psd_QPSK.Power), 'b'); hold on;
plot(psd_16QAM.Frequencies, 10*log10(psd_16QAM.Power), 'r');
xlabel('Frecuencia (Hz)');
ylabel('Densidad espectral de potencia (dB/Hz)');
title('PSD de la señal OFDM (QPSK vs 16-QAM)');
legend('QPSK', '16-QAM');
grid on;
saveas(gcf, 'psd_comparativa.png');  % Guardar la gráfica en un archivo
pause; % Pausar para ver el gráfico

disp('Calculando PAPR...');
% Calcular y graficar PAPR (Relación Pico a Promedio en Potencia)
papr_QPSK = papr(ofdm_signal_QPSK);
papr_16QAM = papr(ofdm_signal_16QAM);
figure;
bar([papr_QPSK, papr_16QAM]);
set(gca, 'XTickLabel', {'QPSK', '16-QAM'});
ylabel('PAPR (dB)');
title('PAPR Comparativa entre QPSK y 16-QAM');
grid on;
saveas(gcf, 'papr_comparativa.png');  % Guardar la gráfica en un archivo
pause; % Pausar para ver el gráfico

% Calcular y comparar BER
disp('Calculando BER...');
SNR_dB = 0:2:20; % Rango de SNR
BER_QPSK = zeros(length(SNR_dB), 1);
BER_16QAM = zeros(length(SNR_dB), 1);
for i = 1:length(SNR_dB)
    % Añadir ruido AWGN
    noise_QPSK = awgn(ofdm_signal_QPSK, SNR_dB(i), 'measured');
    noise_16QAM = awgn(ofdm_signal_16QAM, SNR_dB(i), 'measured');
    
    % Decodificación (Recuperación de bits)
    decoded_bits_QPSK = ofdm_receive(noise_QPSK, N, prefix_length, 'QPSK');
    decoded_bits_16QAM = ofdm_receive(noise_16QAM, N, prefix_length, '16-QAM');
    
    % Asegurarse de que los bits decodificados son del mismo tamaño que los generados
    if length(decoded_bits_QPSK) ~= length(bits)
        decoded_bits_QPSK = decoded_bits_QPSK(1:length(bits)); % Recortar o ajustar si es necesario
    end
    if length(decoded_bits_16QAM) ~= length(bits)
        decoded_bits_16QAM = decoded_bits_16QAM(1:length(bits)); % Recortar o ajustar si es necesario
    end
    
    % Calcular BER
    BER_QPSK(i) = sum(bits ~= decoded_bits_QPSK) / length(bits);
    BER_16QAM(i) = sum(bits ~= decoded_bits_16QAM) / length(bits);
end

% Graficar BER comparativa
disp('Graficando BER...');
figure;
semilogy(SNR_dB, BER_QPSK, 'b-o', 'LineWidth', 2); hold on;
semilogy(SNR_dB, BER_16QAM, 'r-x', 'LineWidth', 2);
xlabel('SNR (dB)');
ylabel('Tasa de Error de Bit (BER)');
title('Comparativa de BER: QPSK vs 16-QAM en OFDM');
legend('QPSK', '16-QAM');
grid on;
saveas(gcf, 'ber_comparativa.png');  % Guardar la gráfica en un archivo
pause; % Pausar para ver el gráfico

disp('Proceso completado.');

% Funciones auxiliares
% Modulación QPSK
function mod_signal = qpsk_mod(bits)
    mod_signal = 1/sqrt(2) * (1 - 2*bits(1:2:end)) + 1i * 1/sqrt(2) * (1 - 2*bits(2:2:end));
end

% Modulación 16-QAM
function mod_signal = qam_mod(bits, M)
    symbols = reshape(bits, log2(M), []);
    decimal = bi2de(symbols', 'left-msb')';
    mod_signal = qammod(decimal, M);
end

% Transmisión OFDM con prefijo cíclico
function ofdm_signal = ofdm_transmit(mod_signal, N, prefix_length)
    % Agrupar las señales en bloques de N subportadoras
    signal_blocks = reshape(mod_signal, N, []);
    
    % Transformada inversa de Fourier para cada bloque
    ifft_signal = ifft(signal_blocks);
    
    % Añadir prefijo cíclico
    prefix = ifft_signal(end-prefix_length+1:end, :);
    ofdm_signal = [prefix; ifft_signal];
    
    % Convertir la señal de OFDM a una forma plana
    ofdm_signal = ofdm_signal(:);
end

% Función para calcular PSD
function psd_data = psd(signal, Fs)
    [psd_data.Power, psd_data.Frequencies] = pwelch(signal, [], [], [], Fs);
end

% Calcular PAPR (Relación Pico a Promedio en Potencia)
function papr_value = papr(ofdm_signal)
    peak_power = max(abs(ofdm_signal).^2);
    avg_power = mean(abs(ofdm_signal).^2);
    papr_value = 10*log10(peak_power / avg_power);
end

% Decodificación OFDM
function decoded_bits = ofdm_receive(ofdm_signal, N, prefix_length, mod_type)
    % Eliminar prefijo cíclico
    signal_no_prefix = ofdm_signal(prefix_length+1:end);
    
    % Reformar la señal de nuevo en bloques
    num_samples = length(signal_no_prefix);
    num_samples_to_use = floor(num_samples / N) * N;  % Ajustar a un múltiplo de N
    signal_no_prefix = signal_no_prefix(1:num_samples_to_use);  % Recortar la señal
    
    signal_blocks = reshape(signal_no_prefix, N, []);
    
    % Aplicar la Transformada Rápida de Fourier
    fft_signal = fft(signal_blocks);
    
    % Decodificación de acuerdo con la modulación seleccionada
    if strcmp(mod_type, 'QPSK')
        decoded_bits = qpsk_demod(fft_signal);
    elseif strcmp(mod_type, '16-QAM')
        decoded_bits = qam_demod(fft_signal, 16);
    end
end

% Demodulación QPSK
function decoded_bits = qpsk_demod(symbols)
    % Asegurarse de que el número de símbolos coincida con los bits
    num_symbols = numel(symbols);
    decoded_bits = zeros(2 * num_symbols, 1);
    
    % Decodificación basada en los símbolos de QPSK
    real_part = real(symbols) > 0;
    imag_part = imag(symbols) > 0;
    
    % Asegurar que los tamaños sean consistentes
    decoded_bits(1:2:end) = real_part;
    decoded_bits(2:2:end) = imag_part;
end

% Demodulación 16-QAM
function decoded_bits = qam_demod(symbols, M)
    symbols = qamdemod(symbols, M);
    decoded_bits = de2bi(symbols, log2(M), 'left-msb')';
    decoded_bits = decoded_bits(:);
end



