function printBitsAsString(bits)
    % Convert bits to string
    str = char(bin2dec(num2str(reshape(bits,[],8)))).';
    
    % Print the string in chunks of 80 characters
    chunkSize = 80;
    numChunks = ceil(length(str) / chunkSize);
    for i = 1:numChunks
        startIdx = (i - 1) * chunkSize + 1;
        endIdx = min(i * chunkSize, length(str));
        fprintf('%s\n', str(startIdx:endIdx));
    end
end
