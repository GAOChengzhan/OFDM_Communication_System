function [output_symbols,ltf_freq] = addLTF(input_symbols)
    % Generate LTF symbols
    ltf_freq = genLTFFrequencySymbols();
    ltf_time = genLTFTimeSymbols(ltf_freq);
    
    % Append to the input symbols
    output_symbols = [ltf_time, input_symbols];
end

function ltf_freq = genLTFFrequencySymbols()
    ltf_freq = complex(zeros(1, 64));
    ltf_freq(end-25:end) = [1, 1, -1, -1, 1, 1, -1, 1, -1, 1, 1, 1, 1, 1, 1, -1, -1, 1, 1, -1, 1, -1, 1, 1, 1, 1];
    ltf_freq(1:27) = [0, 1, -1, -1, 1, 1, -1, 1, -1, 1, -1, -1, -1, -1, -1, 1, 1, -1, -1, 1, -1, 1, -1, 1, 1, 1, 1];
end

function ltf_time = genLTFTimeSymbols(ltf_freq)
    ltf_single = ifft(ltf_freq);
    ltf_time = [ltf_single(end-31:end), ltf_single, ltf_single];
end
