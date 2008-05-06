% display a plate in a single imagefile
function [] = display_plate (imgFile)

% Add folder holding functions for plate detection
addpath('detection');

% find coordinates of plate
[xMin, xMax, yMin, yMax] = getCoord(imgFile);

% read image and display plate
img = imread(imgFile);
figure(1), imshow(img(yMin:yMax,xMin:xMax,:));

return