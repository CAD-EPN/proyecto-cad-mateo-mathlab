# proyecto-cad-mateo-mathlab

Este proyecto fue realizado en MATLAB y cubre varios pasos básicos en el procesamiento de señales de audio, desde la adquisición hasta la reconstrucción de la señal.

# Objetivos

- Cargar una señal de audio (.wav)
- Codificar la señal utilizando PCM
- Realizar modulación 16-QAM
- Ver el comportamiento de la señal en tiempo y frecuencia
- Reconstruir la señal y calcular algunas métricas

# ¿Cómo usar este repositorio?

1. Descarga el archivo `jeff.wav` y ponlo en la misma carpeta que este código.
2. Ejecuta el código en MATLAB. El código está dividido en pasos:
   - Paso 1: Adquisición de la señal (paar este paso necesitas tener guardada un arichivo de auidio tipo .wav y colocar el nombre en el apartado indicado)
   - Paso 2: Codificación de la señal 
   - Paso 3: Compresion PCM 
   - Paso 4: Canal ruidoso 
   - Paso 5: Modulación de la señal
   - Paso 6: ODFM
   - Paso 7: Demodulación y reconstrucción
3. Revisa los resultados:
   - Las gráficas generadas
   - El archivo de texto con el cálculo del SNR

#Archivos generados

- Gráficas:
  - `grafica_tiempo_frecuencia.png`
  - `grafica_codificacion.png`
  - `grafica_constelacion_qam.png`
  - `signal_reconstruction_from_mat_plot.png`
  - `grafica_compression_mse.png`
- El archivo `metrics_from_mat.txt` con el SNR calculado.

# Requisitos

- MATLAB (si no lo tienes, puedes descargarlo desde su página oficial o utilizarlo online)
- Asegúrate de tener el archivo de audio `audio.wav`

# Autor
Este proyecto fue realizado por Mateo Rosero y Jefferson Quispe, estudiantes de la Escuela Politecnica Nacional
