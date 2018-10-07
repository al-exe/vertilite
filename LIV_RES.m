% RES FINDER: ver 1.0
% Date: 06/07/18
% Author: Alex Lee

rescache = zeros(10, 1);

range = 50:50:150;
rangelength = length(range);

for x = 1 : rangelength
    filename = 'data.xlsx';
    data = xlsread(filename, 1, 'A2:D100');

    % ### VARIABLES AND CONSTRAINTS ### %
    numberofpoints = rangelength;
    mincurrent = range(x);
    maxcurrent = 110;

    % minimum current - left tail
    while data(1, 1) < mincurrent
        data = data(2:end, :);
    end

    % maximum current - right tail
    while data(end, 1) > maxcurrent
        data = data(1: (end - 1), :);
    end
    
    deltav = data(end, 3) - data(1, 3);
    deltac = data(end, 1) - data(1, 1);
    res = deltav /deltac;
        
    rescache(x, 1) = res; 
end