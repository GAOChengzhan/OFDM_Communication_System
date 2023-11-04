function OFDM_symbols = BPSK_modulate(bits, data_positions, pilot_positions)
    % Perform BPSK modulation
    bpsk_symbols = pskmod(bits,2);
    bpsk_symbols = reshape(bpsk_symbols,[],48);
    
    % Allocate and place symbols into OFDM frame
    numRows = size(bpsk_symbols, 1);
    OFDM_symbols = complex(zeros(numRows,64)); 
    OFDM_symbols(:,data_positions) = bpsk_symbols;
    % Assume all of the 4 pilots are fixed to 1 + 0 * j
    OFDM_symbols(:,pilot_positions) = 1;
end