% Version 2.2
% Date: 06/15/2018
% Author: Alex Lee
% Note: fixed "donut" issue, now to fix "croissant" issue

close all; clc;
 
file = uigetfile({'*.jpg;*.png;*.bmp;*.tif'}); % acceptable file types
Info = imfinfo(file); 
disp(Info);
 
img = imread(file); % load the image to be processed
labelimg = img; % used for labeling dots
fontsize = 12;
 
% split the image into 3 color channels
imgR = img(:, :, 1); % Red channel
imgG = img(:, :, 2); % Green channel
imgB = img(:, :, 3); % Blue channel

% remove background noise, may not be necessary. 
backgroundR = imopen(imgR, strel('disk', 50));
imgR = imgR - backgroundR;
backgroundG = imopen(imgG, strel('disk', 50));
imgG = imgG - backgroundG;
backgroundB = imopen(imgB, strel('disk', 50));
imgB = imgB - backgroundB;

grayimgR = double(imgR);
grayimgG = double(imgG);
grayimgB = double(imgB);
 
levelR = graythresh(imgR); % Global image threshold RED
binR = imbinarize(imgR, levelR);
levelG = graythresh(imgG); % Global image threshold GREEN
binG = imbinarize(imgG, levelG);
levelB = graythresh(imgB); % Global image threshold BLUE
binB = imbinarize(imgB, levelB);
 
removeP = 20;  % small spot threshold = 20 pixels  (has problems when there is dead spot)
binR = bwareaopen(binR, removeP);  % remove objects smaller than certain pixels.
binG = bwareaopen(binG, removeP);  
binB = bwareaopen(binB, removeP);
 
% create label matrices of colors
[BR,LR] = bwboundaries(binR);
[BG,LG] = bwboundaries(binG);
[BB,LB] = bwboundaries(binB);

% Threshold / binary image cleaning:
% ######################################################### %
% Red "donut" removal - use LR as new binR
for xR = 1 : Info.Width
    for yR = 1 : Info.Height
        if LR(yR, xR) ~= 0
            LR(yR, xR) = 1;
        end
    end
end

% Green "donut" removal - use LG as new binG
for xG = 1 : Info.Width
    for yG = 1 : Info.Height
        if LG(yG, xG) ~= 0
            LG(yG, xG) = 1;
        end
    end
end

% Blue "donut" removal - use LB as new binB
for xB = 1 : Info.Width
    for yB = 1 : Info.Height
        if LB(yB, xB) ~= 0
            LB(yB, xB) = 1;
        end
    end
end
% ######################################################### % 

% matrix multiply each color channel by its corresponding binarized channel
intR = double(grayimgR) .* double(LR);
intG = double(grayimgG) .* double(LG);
intB = double(grayimgB) .* double(LB);

% apply "connected components" to each resulting channel
ccR = bwconncomp(intR);
ccG = bwconncomp(intG);
ccB = bwconncomp(intB);

% create a label matrix of binarized images
labelR = bwlabel(binR);
labelG = bwlabel(binG);
labelB = bwlabel(binB);

% calculate coordinates of all points for labeling
coordinates = zeros(ccR.NumObjects, 2);
for dot = 1 : ccR.NumObjects
    [r, c] = find(labelR == dot);
    rc = [r c];
    coordinates(dot, 2) = rc(1, 1); 
    coordinates(dot, 1) = rc(1, 2);
end

% insert number labeling into image
for dot = 1 : ccR.NumObjects
    labelimg = insertText(labelimg, coordinates(dot, :), dot, 'FontSize', fontsize);
end

% Intensity of every dot in each individual color channel:
% ######################################################### % 
dotIntensityR = zeros(ccR.NumObjects, 1); % RED intensity
for i = 1: ccR.NumObjects 
    for j = 1: length(ccR.PixelIdxList{i})
        dotIntensityR(i, 1) = dotIntensityR(i, 1) + intR(ccR.PixelIdxList{i}(j));
    end
end
 
dotIntensityG = zeros(ccG.NumObjects, 1); % GREEN intensity
for i = 1: ccG.NumObjects
    for j = 1: length(ccG.PixelIdxList{i})
        dotIntensityG(i, 1) = dotIntensityG(i, 1) + intG(ccG.PixelIdxList{i}(j));
    end
end
 
dotIntensityB = zeros(ccB.NumObjects, 1); % BLUE intensity
for i = 1: ccB.NumObjects
    for j = 1: length(ccB.PixelIdxList{i})
        dotIntensityB(i, 1) = dotIntensityB(i, 1) + intB(ccB.PixelIdxList{i}(j));
    end
end
% ######################################################### % 

% Area of every dot in each individual color channel:
% ######################################################### % 
dotAreaR = zeros(ccR.NumObjects, 1); % red area
clusterdataR = regionprops(ccR, 'basic');
for i = 1: ccR.NumObjects 
    dotAreaR(i, 1) = clusterdataR(i).Area;
end 

dotAreaG = zeros(ccG.NumObjects, 1); % blue area
clusterdataG = regionprops(ccG, 'basic');
for i = 1: ccG.NumObjects 
    dotAreaG(i, 1) = clusterdataG(i).Area;
end
 
dotAreaB = zeros(ccB.NumObjects, 1); % green area
clusterdataB = regionprops(ccB, 'basic');
for i = 1: ccB.NumObjects 
    dotAreaB(i, 1) = clusterdataB(i).Area;
end
% ######################################################### %

% centroids / finding the minimum emitter distance
centroidprop = regionprops(binR, 'centroid');
centroids = cat(1, centroidprop.Centroid);
 
centerOfCentroids = [mean(centroids(:, 1)), mean(centroids(:, 2))];
topcoord = min(centroids(:, 2));
bottomcoord = max(centroids(:, 2));

dist = topcoord - centerOfCentroids(1, 2);
topboundary = dist/2 + centroids(:, 1);
bottomboundary = centroids(:, 1) - dist/2;

boundaries = zeros(10, 2);
boundaryindex = [];
centers = zeros(10, 2);
centerindex = [];

%{
% centroids / finding the minimum emitter distance
centroidprop = regionprops(binR, 'centroid');
centroids = cat(1, centroidprop.Centroid);
 
minx = min(centroids(:, 1));
miny = min(centroids(:, 2));
 
minx2 = Info.Width - max(centroids(:, 1));
miny2 = Info.Height - max(centroids(:, 2));
 
absmin= min(min(miny, miny2), min(minx, minx2));

boundaries = zeros(10, 2);
boundaryindex = [];
centers = zeros(10, 2);
centerindex = [];
%}
%{ 
for dot = 1 : ccR.NumObjects
    if centroids(dot, 1) < absmin * 3 || centroids(dot, 2) < absmin * 3 || Info.Height - centroids(dot, 2) < absmin * 3 || Info.Width - centroids(dot, 1) < absmin * 3
        boundaries(dot, 1) = centroids(dot, 1);
        boundaries(dot, 2) = centroids(dot, 2);
        boundaryindex = [boundaryindex, dot];
    else
        centers(dot, 1) = centroids(dot, 1);
        centers(dot, 2) = centroids(dot, 2);
        centerindex = [centerindex, dot];
    end
end
centerindex = centerindex.';
boundaryindex = boundaryindex.';
%}

% calculate average intensity of boundary vs center
total = 0;
centerheight = size(centerindex);
for centerdot = 1 : centerheight(1)
    total = total + dotIntensityR(centerindex(centerdot), 1);
end
centerint = total / centerheight(1); % Average int. of centers
 
total = 0;
boundaryheight = size(boundaryindex);
for boundarydot = 1 : boundaryheight(1)
    total = total + dotIntensityR(boundaryindex(boundarydot), 1);
end
boundaryint = total / boundaryheight(1); % Average int. of boundaries


% ### AREA DATA ANALYTICS ### %
% ######################################################### %
dsAreaR = datastats(dotAreaR);  % red area data statistics 
areastatR = struct2cell(dsAreaR);
areaStd_percR = dsAreaR.std/dsAreaR.mean * 100;
areastatR = cat(1, areastatR, areaStd_percR);
 
dsAreaG = datastats(dotAreaG);  % green area data statistics 
areastatG = struct2cell(dsAreaG);
areaStd_percG = dsAreaG.std/dsAreaG.mean * 100;
areastatG = cat(1, areastatG, areaStd_percG);
 
dsAreaB = datastats(dotAreaB);  % blue area data statistics 
areastatB = struct2cell(dsAreaB);
areaStd_percB = dsAreaB.std/dsAreaB.mean * 100;
areastatB = cat(1, areastatB, areaStd_percB);
% ######################################################### %

% ### INT. DATA ANALYTICS ### %
% ######################################################### %
dsR = datastats(dotIntensityR);  % red int. data statistics 
statR = struct2cell(dsR);
Std_percR = dsR.std/dsR.mean * 100;
statR = cat(1, statR, Std_percR);
 
dsG = datastats(dotIntensityG);  % green int. data statistics 
statG = struct2cell(dsG);
Std_percG = dsG.std/dsG.mean * 100;
statG = cat(1, statG, Std_percG);
 
dsB = datastats(dotIntensityB);  % blue int. data statistics 
statB = struct2cell(dsB);
Std_percB = dsB.std/dsB.mean * 100;
statB = cat(1, statB, Std_percB);
% ######################################################### %
