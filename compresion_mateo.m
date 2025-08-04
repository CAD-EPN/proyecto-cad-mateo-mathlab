% Paso 3: Compresión µ-law y ADPCM
clear; clc;

% Cargar el archivo raw
load('raw_signal_mateo.mat'); 

% Parámetros
mu = 255;  % Parámetro µ para compresión µ-law

% 1. Compresión µ-law
mu_law_signal = sign(signal) .* log(1 + mu * abs(signal)) / log(1 + mu); % Compresión µ-law
mu_law_signal = mu_law_signal / max(abs(mu_law_signal));  % Normalización

% 2. Compresión ADPCM
% Implementar la compresión ADPCM (usamos una aproximación simple aquí)
% Primero, calculamos las diferencias (delta) entre las muestras consecutivas
adpcm_signal = diff(signal);  % Diferencias entre muestras
adpcm_signal = adpcm_signal / max(abs(adpcm_signal));  % Normalización para ADPCM

% 3. Calcular la razón de compresión para µ-law
compression_ratio_mu = length(signal) / length(mu_law_signal);

% 4. Calcular el MSE para ADPCM
mse_adpcm = mean((signal(2:end) - adpcm_signal).^2);  % Comparar señal original y ADPCM

% Graficar las señales en una sola figura con tres subgráficas
figure;

% Subgráfico 1: Señal Original
subplot(3, 1, 1);
plot(signal);
title('Señal Original');
xlabel('Muestras');
ylabel('Amplitud');
grid on;

% Subgráfico 2: Señal Comprimida con µ-law
subplot(3, 1, 2);
plot(mu_law_signal);
title('Señal Comprimida con µ-law');
xlabel('Muestras');
ylabel('Amplitud');
grid on;

% Subgráfico 3: Señal Comprimida con ADPCM
subplot(3, 1, 3);
plot(adpcm_signal);
title('Señal Comprimida con ADPCM (Diferencias)');
xlabel('Muestras');
ylabel('Amplitud');
grid on;

% Guardar esta figura como una sola imagen
saveas(gcf, 'grafica_comparativa.png'); 

% Mostrar resultados de la compresión
disp(['Razón de compresión para µ-law: ', num2str(compression_ratio_mu)]);
disp(['MSE para ADPCM: ', num2str(mse_adpcm)]);

