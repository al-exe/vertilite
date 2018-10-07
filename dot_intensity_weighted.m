% Verson 1.0
% Date: May 24, 2018
% Author: Alex Lee

close all; clc;

file= uigetfile({'*.jpg;*.png;*.bmp;*.tif'}); % acceptable file types
Info = imfinfo(file); 
disp(Info);

img1 = imread(file); % Load the image to be processed

% split the image into 3 color channels:
imgR1 = img1(:, :, 1); % Red component
imgG1 = img1(:, :, 2); % Green component
imgB1 = img1(:, :, 3); % Blue component
% 255 is the max value in 8 bit

% ### MODIFICATION ### %

backgroundR = imopen(imgR1, strel('disk', 50));  % remove background noise, may not be necessary. 
imgR1 = imgR1 - backgroundR;
backgroundG = imopen(imgG1, strel('disk', 50));
imgG1 = imgG1 - backgroundG;
backgroundB = imopen(imgB1, strel('disk', 50));
imgB1 = imgB1 - backgroundB;

% 0.2989 * R + 0.5870 * G + 0.1140 * B 
GrayimgR1 = double(imgR1) * 0.2989;
GrayimgG1 = double(imgG1) * 0.5870;
GrayimgB1 = double(imgB1) * 0.1140;

% binarize each color channel:
binR1 = imbinarize(imgR1);
binG1 = imbinarize(imgG1);
binB1 = imbinarize(imgB1);

removeP = 20;  % small spot threshold = 20 pixels  (has problems when there is dead spot)
binR1 = bwareaopen(binR1, removeP);  % remove objects smaller than certain pixels.
binG1 = bwareaopen(binG1, removeP);  
binB1 = bwareaopen(binB1, removeP);  

% matrix multiply each color channel by its corresponding binarized channel
intR1 = double(GrayimgR1) .* double(binR1);
intG1 = double(GrayimgG1) .* double(binG1);
intB1 = double(GrayimgB1) .* double(binB1);

% apply connected components to each resulting channel (i.e AimgR1):
ccR1 = bwconncomp(intR1);
ccG1 = bwconncomp(intG1);
ccB1 = bwconncomp(intB1);

% calculate dot intensity for each connected components channel:
DotIntensityR1 = zeros(ccR1.NumObjects, 1);
for i = 1: ccR1.NumObjects 
    for j = 1: length(ccR1.PixelIdxList{i})
        DotIntensityR1(i, 1) = DotIntensityR1(i, 1) + intR1(ccR1.PixelIdxList{i}(j));
    end
end

DotIntensityG1 = zeros(ccG1.NumObjects, 1); % GREEN intensity
for i = 1: ccG1.NumObjects
    for j = 1: length(ccG1.PixelIdxList{i})
        DotIntensityG1(i, 1) = DotIntensityG1(i, 1) + intG1(ccG1.PixelIdxList{i}(j));
    end
end

DotIntensityB1 = zeros(ccB1.NumObjects, 1); % BLUE intensity
for i = 1: ccB1.NumObjects
    for j = 1: length(ccB1.PixelIdxList{i})
        DotIntensityB1(i, 1) = DotIntensityB1(i, 1) + intB1(ccB1.PixelIdxList{i}(j));
    end
end

% ### Begin data analytics ###

dsR = datastats(DotIntensityR1);  % RED data statistics 
statR = struct2cell(dsR);
Std_percR = dsR.std/dsR.mean * 100;
statR = cat(1, statR, Std_percR);

dsG = datastats(DotIntensityG1);  % GREEN data statistics 
statG = struct2cell(dsG);
Std_percG = dsG.std/dsG.mean * 100;
statG = cat(1, statG, Std_percG);

dsB = datastats(DotIntensityB1);  % BLUE data statistics 
statB = struct2cell(dsB);
Std_percB = dsB.std/dsB.mean * 100;
statB = cat(1, statB, Std_percB);

%{
% LASER1.jpg HISTOGRAM SETTINGS, comment out if using LASER2.jpg
histogram(DotIntensityR1, 'BinLimits', [1,8000], 'BinWidth', 200);
ylim([0 200]);
figure;
histogram(DotIntensityG1, 'BinLimits', [1,8000], 'BinWidth', 200);
ylim([0 200]);
figure;
histogram(DotIntensityB1, 'BinLimits', [1,8000], 'BinWidth', 200);
ylim([0 200]);
%}

%{
% LASER2.jpg HISTOGRAM SETTINGS, comment out if using LASER1.jpg
histogram(DotIntensityR1, 'BinLimits', [1,30000], 'BinWidth', 200);
ylim([0 200]);
figure;
histogram(DotIntensityG1, 'BinLimits', [1,30000], 'BinWidth', 200);
ylim([0 200]);
figure;
histogram(DotIntensityB1, 'BinLimits', [1,30000], 'BinWidth', 200);
ylim([0 200]);
%}

%display(ds);