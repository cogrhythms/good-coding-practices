function filteredData = filterData(data, freqBand, SampFreq)

% Filter data in selected frequency band

filterOrder = 3;

% upper cut off frequency needs to be less than Nyquist
if freqBand(2)==SampFreq/2
    freqBand(2) = SampFreq/2-0.001;
end

% construct filter
if freqBand(1)==0
    % low-pass filter
    [b, a] = butter(filterOrder, freqBand(2)/(SampFreq/2));
else
    % band-pass filter
    [b, a] = butter(filterOrder, freqBand/(SampFreq/2));
end

% filter data
filteredData = filtfilt(b, a, data);