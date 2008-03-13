% A program to process a folder of images of cars with
% visible license plates. Outputs statistics of the job
% On what percentage of the images were plates found?
% What percentage of plates were read correctly?
% What percentage of identified characters were read correctly?

% Last 7 characters before file extension must be correct license
% plate for image.   


% imagesFolder = Path to folder with images 
function [] = main(imagesFolder, numberOfImagesToProcess)


% Setup variables

% Add folder holding functions for plate detection
addpath('detection');

% noOfImages = 0;
percentageOfPlatesFound = 0;
percentageOfPlatesRead = 0;
percentageOfCharsRead = 0;

% Get filelist
fileList = dir([imagesFolder '*.JPG']);
noOfImages = length(fileList);


if noOfImages < 1 
  'No images found. Aborting.'
else
  ['Going to work on' noOfImages ' images.']
end

for i = 1:noOfImages
%for i = 1:1
  % FIND PLATE
  plateCoords = detect_lines([imagesFolder fileList(i).name])
  %plateImage = detect2([imagesFolder fileList(i).name])
  
  % ROTATE
  rotatedPlateImg = plate_rotate([imagesFolder fileList(i).name],plateCoords(1),plateCoords(2),plateCoords(3),plateCoords(4));
  
  % SEGMENT CHARS
  %chars = char_segment(rotatedPlateImg);
  
  % Wait for user to press a key
  pause();
  % SomeFunction([imagesFolder fileList(i).name]);
  

  % RECOGNIZE PATTERNS
end


% PRINT STATS
