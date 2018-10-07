% THRESHOLD CURRENT FINDER: ver 1.0
% Date: 06/07/18
% Author: Alex Lee

secache = zeros(10, 1);

range = 100:50:1150;
rangevector = range.';
rangelength = length(range);

for x = 1 : rangelength
    filename = 'data.xlsx';
    data = xlsread(filename, 1, 'A2:D100');

    % ### VARIABLES AND CONSTRAINTS ### %
    center = 1400;
    lowerbound = center - range(x);
    upperbound = center + range(x);
 
    % minimum PCE
    while data(1, 4) == 0
        data = data(2:end, :);
    end
    
    % minimum current - left tail
    while data(1, 1) < (lowerbound - 10)
        data = data(2:end, :);
    end
    
    % maximum current - right tail
    while data(end, 1) > (upperbound + 10)
        data = data(1: (end - 1), :);
    end
    
    a = horzcat(roundn(data(:, 1), 1), data);
    
    deltaL = a(end, 3) - a(1, 3);
    deltaI = a(end, 2) - a(1, 2);
    
    se = deltaL / deltaI;
    secache(x, 1) = se; 
end