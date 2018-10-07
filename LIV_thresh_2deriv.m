% THRESHOLD CURRENT FINDER: ver 1.0
% Date: 06/07/18
% Author: Alex Lee

    filename = 'data.xlsx';
    data = xlsread(filename, 1, 'A2:D100');

    % ### VARIABLES AND CONSTRAINTS ### %
    center = 1400;
    mincurrent = 0;
    maxcurrent = 2610;
    
    % minimum current - left tail
    while data(1, 1) < mincurrent
        data = data(2:end, :);
    end
    
    % maximum current - right tail
    while data(end, 1) > maxcurrent
        data = data(1: (end - 1), :);
    end
    
    diffP = diff(data(:, 2));
    diffC = diff(data(:, 1));
    
    secache = diffP ./ diffC;
    current2cache = (diffC / 2) + (data(1:end-1, 1));
    finalcache = horzcat(current2cache, secache);
    
    %derivcache(x, 1) = firstderiv;
