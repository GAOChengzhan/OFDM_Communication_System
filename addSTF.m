function [output_symbols,stf_single] = addSTF(input_symbols)
    % Generate STF symbols
    stf_freq = genSTFFrequencySymbols();
    [stf_time,stf_single] = genSTFTimeSymbols(stf_freq);
    
    % Visualize
    plotUtility('single', linspace(1,64, 64), ...
        abs(fftshift(fft(input_symbols,64))).^2, ...
        [], 'Power Spectrum Density of the OFDM Data Symbols', ...
        'Indices', 'Power Spectrum Density', '', '', ...
        'Power_Spectrum_Density.png');
    plotUtility('single',linspace(1,size(stf_time,2),size(stf_time,2)), ...
        abs(stf_time), [], 'Magnitude of the Samples in the STF', ...
        'Sample Indices', 'Magnitude','', '','Magnitude_Samples_SFT.png');

    % Append to the input symbols
    output_symbols = [stf_time, input_symbols];
end

function stf_freq = genSTFFrequencySymbols()
    stf_freq = complex(zeros(1, 64));
    stf_freq(end-25:end) = sqrt(13/6) * [0, 0, 1+1i, 0, 0, 0, -1-1i, 0, 0, 0, 1+1i, 0, 0, 0, -1-1i, 0, 0, 0, -1-1i, 0, 0, 0, 1+1i, 0, 0, 0];
    stf_freq(1:27) = sqrt(13/6) * [0, 0, 0, 0, -1-1i, 0, 0, 0, -1-1i, 0, 0, 0, 1+1i, 0, 0, 0, 1+1i, 0, 0, 0, 1+1i, 0, 0, 0, 1+1i, 0, 0];
end

function [stf_time, stf_single] = genSTFTimeSymbols(stf_freq)
    stf_single = ifft(stf_freq);
    stf_single = stf_single(1:16);
    stf_time = repmat(stf_single, [1, 10]);
end