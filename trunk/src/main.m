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
noOfPlatesFound = 0;
percentageOfPlatesFound = 0;
percentageOfPlatesRead = 0;
percentageOfCharsRead = 0;

% Number of times there weas no candidate
noCandidate = 0;

% echo time
datestr(now)

% Get filelist
fileList = dir([imagesFolder '*.JPG']);
noOfImages = length(fileList);


if noOfImages < 1 
  'No images found. Aborting.'
else
  ['Going to work on ' int2str(noOfImages) ' images.']
end

for i = 1:noOfImages
%for i = 1:1

  %%%%%%%%%%%%%%
  % FIND PLATE %
  %%%%%%%%%%%%%%

  % Get plate coordinates from filename
  % xMin, xMax, yMin, yMax
  realPlateCoords = [str2num(fileList(i).name(1,3:6)), str2num(fileList(i).name(1,8:11)), ...
                     str2num(fileList(i).name(1,13:16)), str2num(fileList(i).name(1,18:21))];
 
  % Analyze image and get coordinates of plate
  plateCoords = detect_lines([imagesFolder fileList(i).name]);
  %plateCoords = detect2([imagesFolder fileList(i).name])
  %plateCoords = detect4([imagesFolder fileList(i).name])
  %plateImage = detect3([imagesFolder fileList(i).name])
  
  % Determine if plate is within found coordinates 
  if (realPlateCoords(1) >= plateCoords(1) && realPlateCoords(2) <= plateCoords(2) && ...
   realPlateCoords(3) >= plateCoords(3) && realPlateCoords(4) <= plateCoords(4))
    noOfPlatesFound = noOfPlatesFound + 1;
  else
    % Echo name of image where plate was not found
    fileList(i).name
    % No candidate was found
    if sum(plateCoords) == 0
      noCandidate = noCandidate + 1;
    end
  end   



  %%%%%%%%%%
  % ROTATE %
  %%%%%%%%%%
  %rotatedPlateImg = plate_rotate([imagesFolder fileList(i).name],plateCoords(1),plateCoords(2),plateCoords(3),plateCoords(4));
  
  % SEGMENT CHARS
  %chars = char_segment(rotatedPlateImg);
  
  % Wait for user to press a key
  % pause();
  
  % SomeFunction([imagesFolder fileList(i).name]);
  

  % RECOGNIZE PATTERNS
end


% PRINT STATS

percentageOfPlatesFound = noOfPlatesFound*(100/noOfImages)

% What percentage of the candidates were correct
correctnessOfCandidates = noOfPlatesFound*(100/(noOfImages-noCandidate))

%noOfPlatesNotFound = noOfImages - noOfPlatesFound

% echo time
datestr(now)
