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
addpath('segmentation');
addpath('patternreg');

% noOfImages = 0;
noOfPlatesFound = 0;
noOfPlatesRead = 0;
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

% for histogram method
%olympusFile = load('/Users/epb/Documents/datalogi/3aar/bachelor/licenseplate/src/detection/freqTableOlympus.mat');
%canonFile = load('/Users/epb/Documents/datalogi/3aar/bachelor/licenseplate/src/detection/freqTableCanon.mat');
%freqTable = olympusFile.freqTableOlympus;
%freqTable = canonFile.freqTableCanon;
%horizontalTable = canonFile.horizontalTable;
%verticalTable = canonFile.verticalTable;

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
  %plateCoords = histo_detect([imagesFolder fileList(i).name], freqTable, true);
  %plateCoords = histo_detect([imagesFolder fileList(i).name], horizontalTable, verticalTable, true);
  
  % Determine if plate is within found coordinates 
  if (realPlateCoords(1) >= plateCoords(1) && realPlateCoords(2) <= plateCoords(2) && ...
   realPlateCoords(3) >= plateCoords(3) && realPlateCoords(4) <= plateCoords(4))
    noOfPlatesFound = noOfPlatesFound + 1;
  else
    % Echo name of image where plate was not found
    ['Plate not found in ' fileList(i).name]
    % No candidate was found
    if sum(plateCoords) == 0
      noCandidate = noCandidate + 1;
    end
  end   



  %%%%%%%%%%
  % ROTATE %
  %%%%%%%%%%
  
  %[rotatedImg, plateCoords] = plate_rotate_radon([imagesFolder fileList(i).name],plateCoords,true);
  %[rotatedImg, plateCoords] = plate_rotate_hough([imagesFolder
  %fileList(i).name],plateCoords,false);
  
  %%%%%%%%%%%%%%%%%
  % SEGMENT CHARS %
  %%%%%%%%%%%%%%%%%
  
  % charCoords are relative to plateimage
  foundChars = 0;
  %[chars, charCoords, foundChars] = char_segment_cc(rotatedImg,plateCoords,true);
  %[chars, charCoords, foundChars] = char_segment_ptv(rotatedImg,plateCoords,true);
  
  %%%%%% Determine if found chars contains coordinates of real chars. %%%%%
  %figure(19), imshow(imread([imagesFolder fileList(i).name]));
  
  if foundChars == 7

    % find vertical middle of plate and its length plus the width of a char
    plateMiddle = realPlateCoords(4) - ...
      (realPlateCoords(4) - realPlateCoords(3))/2;
    plateLength = realPlateCoords(2) - realPlateCoords(1);
    
    % set approximate char width and space widths. TO-DO!!
    relativeCharWidth = 1/8;
    relativeSmallSpace = 1/55;
    relativeLargeSpace = 2 * relativeSmallSpace;
    charWidth = relativeCharWidth * plateLength;
    smallSpace = relativeSmallSpace * plateLength;
    largeSpace = relativeLargeSpace * plateLength;

    % find real char coordinates
    realCharCoords = zeros(7,1); % plateMiddle is second coordinate
    %realCharCoords(:,2) = plateMiddle;

    realCharCoords(1) = realPlateCoords(1) + smallSpace + charWidth/2;
    for c = 2:7
      if c ~= 3 && c ~=5
        realCharCoords(c) = realCharCoords(c-1) + smallSpace + charWidth;
      else
        realCharCoords(c) = realCharCoords(c-1) + largeSpace + charWidth;
      end
    end
    
    % calculate char coordinates relative to entire image
    for k = 1:7
      charCoords(k,1:2) = charCoords(k,1:2) + plateCoords(1);
      charCoords(k,3:4) = charCoords(k,3:4) + plateCoords(3);
    end
    
    % calculate no. of correctly read chars
    charsRead = 0;
    for j = 1:7
      %if charCoords(j,1) <= realCharCoords(j) && ...
      %    charCoords(j,2) >= realCharCoords(j) && ...
      %    charCoords(j,3) <= plateMiddle && ...
      %    charCoords(j,4) >= plateMiddle
      charMiddle = [(charCoords(j,1)+charCoords(j,2))/2 (charCoords(j,3)+charCoords(j,4))/2];
      if charMiddle(1) >= realPlateCoords(1) && ...
         charMiddle(1) <= realPlateCoords(2) && ...
         charMiddle(2) >= realPlateCoords(3) && ...
         charMiddle(2) <= realPlateCoords(4)
        charsRead = charsRead + 1;
        
      end
    end
    
    % determine if the plate is correctly read
    if charsRead == 7
      noOfPlatesRead = noOfPlatesRead + 1;
    else
      ['Plate not read in ' fileList(i).name]
      %pause();
    end
  else
    ['Plate not read in ' fileList(i).name]
    %pause();
  end
  
  % Wait for user to press a key
  %pause();
  
  % SomeFunction([imagesFolder fileList(i).name]);
  
  %%%%%%%%%%%%%%%%%%%%%%
  % RECOGNIZE PATTERNS %
  %%%%%%%%%%%%%%%%%%%%%%
  
  
  
end

%%%%%%%%%%%%%%%
% PRINT STATS %
%%%%%%%%%%%%%%%

percentageOfPlatesFound = noOfPlatesFound*(100/noOfImages)

% What percentage of the candidates were correct
correctnessOfCandidates = noOfPlatesFound*(100/(noOfImages-noCandidate))

%noOfPlatesNotFound = noOfImages - noOfPlatesFound
percentageOfPlatesRead = noOfPlatesRead*(100/noOfPlatesFound)

% echo time
datestr(now)
