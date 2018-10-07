% Best LSRL Finder: ver 2.2
% Date: 06/07/18
% Author: Alex Lee

interceptcache = zeros(10, 1);

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
    
    datacache = zeros(10000, 10);
    
    xset = data(:, 1);
    yset = data(:, 3);
    xstat = datastats(xset);
    ystat = datastats(yset);
    xcomp = xset - xstat.mean;
    ycomp = yset - ystat.mean;
    slopenumer = sum(xcomp .* ycomp);
    slopedenom = sum(xcomp.^2);
    slope = slopenumer / slopedenom;
    inter = ystat.mean - slope * xstat.mean;
        
    datacache(X, 1) = slope;
    datacache(X, 2) = inter;
        
    interceptcache(X, 1) = inter; 
end