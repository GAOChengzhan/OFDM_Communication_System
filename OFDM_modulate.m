function output_symbols = OFDM_modulate(input_symbols)
    N = 64;
    prefixLength = 16;

    % Transform symbols from frequency to time domain
    time_samples = ifft(input_symbols, N, 2);
    
    % Add cyclic prefix for OFDM
    cyclic_prefix = time_samples(:, end-prefixLength+1:end);
    withPrefix = [cyclic_prefix, time_samples];
  
    % Flatten the output for transmission
    output_symbols = withPrefix(:).';
end