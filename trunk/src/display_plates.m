% display plates in a folder
function [] = display_plates (imgFolder)

% Add folder holding functions for plate detection
addpath('detection');

fileList = dir([imgFolder '*.JPG']);
noOfFiles = length(fileList);
  
if noOfFiles < 1 
  'No files found. Aborting.'
  return;
end
  
% iterate through files
for i = 1:noOfFiles
  
  imgFile = [imgFolder fileList(i).name];
  
  % find coordinates of plate
  [xMin, xMax, yMin, yMax] = getCoord(imgFile);

  % read image and display plate
  img = imread(imgFile);
  figure(1), imshow(img(yMin:yMax,xMin:xMax,:));

  % wait for user to press key
  pause(1);
  
end

% close figure window
close(1);

return