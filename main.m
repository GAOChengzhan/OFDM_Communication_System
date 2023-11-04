%%% Preparation
clear;
close all;
% Subcarrier allocation 
data_positions = [2:7, 9:21, 23:27, 39:43, 45:57, 59:64];
pilot_positions = [8, 22, 44, 58];

%%% ========== ===========================================  ========== %%%
%%% ========== (1) Packet Construction and OFDM Modulation  ========== %%%
%%% ========== ===========================================  ========== %%%

%%% Step (a) BPSK modulation:
% Random packet of bits
PACKET_LENGTH = 4800;
bits = double(randi([0 1], PACKET_LENGTH, 1));
fprintf("Transmitted Strings:\n");
printBitsAsString(bits);
% BPSK modulation: Convert 0 -> 1 and 1 -> -1
OFDM_symbols = BPSK_modulate(bits, data_positions, pilot_positions); 
freq_domain_symbols = OFDM_symbols;
%%% Step (b) OFDM Modulation:
OFDM_symbols = OFDM_modulate(OFDM_symbols);

%%% Step (c) Add STF and LTF preambles to each data packet
%%% Step (d) Plot the magnitude of samples in the resulting STF. 
[OFDM_symbols,ltf_freq] = addLTF(OFDM_symbols);
[packet_data,stf_single] = addSTF(OFDM_symbols);

%%% ======== ============================================== ========== %%%
%%% ======== (2) Packet transmission and channel distortion ========== %%%
%%% ======== ============================================== ========== %%%

%%% Prepend (e.g., 100) zero samples before the transmitted packet
ZERO_PADDING = 100;
packet_data = [zeros(1, ZERO_PADDING), packet_data];

%%% (i)   Attenuate the signal magnitude
ATTENUATION_FACTOR = 10^(-5);
packet_data = packet_data * ATTENUATION_FACTOR;

%%% (ii)  Apply a global phase shift due to the channel
PHASE_SHIFT = -3 * pi / 4;
packet_data = packet_data * exp(1i * PHASE_SHIFT);

%%% (iii) Compensate for the frequency offset due to radio hardware 
%         imperfections
FREQ_OFFSET = 0.00017; % Frequency offset value
TIME_VECTOR = linspace(1, length(packet_data), length(packet_data));
packet_data = packet_data .* exp(-2i * pi * FREQ_OFFSET * TIME_VECTOR);

%%% (iv)  Introduce Gaussian noise to simulate a noisy channel
NOISE_STDDEV = 10^(-14);
channel_noise = normrnd(0, NOISE_STDDEV, size(packet_data));
packet_data = packet_data + channel_noise;

%%% Visualize the magnitude of the STF after channel distortion
STF_SAMPLES = 160;
plotUtility('single', TIME_VECTOR(1:STF_SAMPLES), ...
  abs(packet_data(:, (ZERO_PADDING + 1):(ZERO_PADDING + STF_SAMPLES))), ...
  [], 'Post-Distortion Sample Magnitudes of the STF', 'Sample Indices', ...
  'Magnitude', '', '', 'STF_Magnitudes_PostDistortion.png');


%%% ====================== ==================== ====================== %%%
%%% ====================== (3) Packet detection ====================== %%%
%%% ====================== ==================== ====================== %%%

%%% Number of samples in the repeated STF section
STF_REPEAT_LENGTH = 16;

%%% Compute the sliding self-correlation and energy
len = length(packet_data) - 2 * STF_REPEAT_LENGTH + 1;
correlation_results = zeros(1, len);
energy_results = zeros(1, len);

for idx = 1:len
    % Segment samples corresponding to repeated STF sections
    stf_1 = packet_data(idx : idx + STF_REPEAT_LENGTH - 1);
    stf_2 = packet_data(idx + STF_REPEAT_LENGTH : ...
                        idx + 2 * STF_REPEAT_LENGTH - 1);

    % Self-correlation
    correlation_results(idx) = abs(dot(stf_1, stf_2));
    
    % Energy computation
    energy_results(idx) = dot(stf_1, stf_1);
end

%%% Identify the start of the STF by thresholding the self-correlation 
%   results
THRESHOLD = 0.9999;
potential_stf_starts = find(correlation_results > ...
                            (THRESHOLD * abs(energy_results)));

%%% Visualization
plotUtility('dual', 1:len, correlation_results, energy_results, ...
    'Self-Correlation and Energy of STF Segments', 'Indices', ...
    'Amplitude', 'Self-Correlation', 'Energy', ...
    'Correlation_Energy_Results.png');

% Display the potential STF start indices
fprintf("Indices of samples where packets are detected:\n");
% Adjust for the sliding window offset
disp(potential_stf_starts +2*STF_REPEAT_LENGTH-1); 


%%% =================== ========================== =================== %%%
%%% =================== (4) Packet synchronization =================== %%%
%%% =================== ========================== =================== %%%
% Calculate the cross-correlation between the data and STF preamble
cross_corr_results = xcorr(packet_data, stf_single);
cross_corr_results = cross_corr_results(length(packet_data) - ...
                    length(stf_single) + 16:end);

%disp(size(cross_correlation))
len_cc = length(cross_corr_results);

% plot cross correlation
plotUtility('single', 1:len_cc, abs(cross_corr_results), [], ...
    'Cross-correlation for Synchronization', 'Indices', 'Amplitude', ...
    '', '', 'Cross_Correlation_Results.png');

% Detecting the start of STF
stf_detection_threshold = 0.9 * max(abs(cross_corr_results));
detected_stf_starts = find(abs(cross_corr_results) > ...
                                stf_detection_threshold);
fprintf("Indices of samples corresponding to the STF starting time:\n");
disp(detected_stf_starts);

%%% =========== ========================================== =========== %%%
%%% =========== (5) Channel estimation and packet decoding =========== %%%
%%% =========== ========================================== =========== %%%

%%% Step (a) leverage the LTF to estimate the frequency offset
% exact starting time of the LTF
ltf_initial_idx = detected_stf_starts(end) + STF_REPEAT_LENGTH;
ltf_segment_1 = packet_data(ltf_initial_idx : ltf_initial_idx + 63);
ltf_segment_2 = packet_data(ltf_initial_idx + 64 : ltf_initial_idx + 127);

estimated_freq_offset = sum(imag(rdivide(ltf_segment_1, ...
                            ltf_segment_2))) / (2*pi*64*64);

fprintf("The frequency offset between the transmitter and receiver:" + ...
    " %f\n", estimated_freq_offset);
packet_data = packet_data .* exp(2i * pi * estimated_freq_offset * ...
                                            (1:length(packet_data)));

%%% Step (b) estimate the channel magnitude/phase distortion to each sample
ltf_segment_1 = packet_data(ltf_initial_idx + 32 : ltf_initial_idx + 95);
ltf_segment_2 = packet_data(ltf_initial_idx + 96 : ltf_initial_idx + 159);

ltf_fft_1 = fft(ltf_segment_1);
ltf_fft_2 = fft(ltf_segment_2);
estimated_channel_distortion = times((ltf_fft_1 + ...
                                ltf_fft_2) / 2, ltf_freq);
fprintf("The channel distortion to each subcarrier \n");
disp(estimated_channel_distortion);

%%% Step (c) decode the digital information in each OFDM data symbol
% (i) run FFT over each OFDM symbol and convert it into a number of 
%     (64) subcarriers
packet_data = packet_data(ltf_initial_idx + 160:end);
prefixed_data = reshape(packet_data, [], 80);
sample_data = prefixed_data(:, 17:end);
ofdm_transformed = fft(sample_data, 64, 2);

% (ii) recover the original BPSK symbols by reverting the channel 
%      distortion
distortion_zero_indices = find(estimated_channel_distortion == 0);   
distortion_nonzero_indices = find(estimated_channel_distortion ~= 0);
ofdm_transformed(:, distortion_nonzero_indices) = ofdm_transformed(:, ...
    distortion_nonzero_indices) ./ repmat(estimated_channel_distortion ...
    (distortion_nonzero_indices), [size(ofdm_transformed, 1), 1]);
ofdm_transformed(:, distortion_zero_indices) = 0;

% (iii) demap the BPSK symbols to {0,1} information bits and convert the
%       bits into characters.
bpsk_demap_data = reshape(ofdm_transformed(:, data_positions), [], 1);
decoded_bits = pskdemod(bpsk_demap_data, 2);

fprintf("Transmitted Strings:\n");
printBitsAsString(decoded_bits);


