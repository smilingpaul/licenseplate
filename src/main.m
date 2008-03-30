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
  %plateCoords = histo_detect([imagesFolder fileList(i).name], freqTable);
  
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
  %rotatedPlateImg = plate_rotate([imagesFolder fileList(i).name],plateCoords(1),plateCoords(2),plateCoords(3),plateCoords(4));
  
  % no figures
  rotatedPlateImg = plate_rotate([imagesFolder fileList(i).name],plateCoords(1),plateCoords(2),plateCoords(3),plateCoords(4),0);
  
  % SEGMENT CHARS
  [chars, charCoords, foundChars] = char_segment_cc(rotatedPlateImg);
  
  % Determine if found chars contains coordinates of real chars. TO-DO!!
  
  if foundChars == 7
  
    %realCharCoords = getRealCharCoords([fileList(i).name]);
    % set approximate char width and space widths
    aproxCharWidth = 1/7;

    % no. of small spaces = 6, large spaces = 2
    %aproxSmallSpc = 0;
    %aproxLargeSpc = 2 * aproxSmallSpc;

    plateMiddle = realPlateCoords(4) - realPlateCoords(3);
    plateLength = realPlateCoords(2) - realPlateCoords(1);
    charWidth = aproxCharWidth * plateLength;

    realCharCoords = zeros(7,2);
    realCharCoords(:,2) = plateMiddle;

    realCharCoords(1,1) = realPlateCoords(1) + charWidth/2;
    for c = 2:7
      realCharCoords(c,1) = realCharCoords(c-1,1) + charWidth;
    end
    
    charsRead = 0;
    for j = 1:7
      if charCoords(j,1) <= realCharCoords(j,1) && charCoords(j,2) >= realCharCoords(j,1) && ...
          charCoords(j,3) <= realCharCoords(j,2) && charCoords(j,4) >= realCharCoords(j,2)
        charsRead = charsRead + 1;
      end
    end
    
    if charsRead == 7
      noOfPlatesRead = noOfPlatesRead + 1;
    else
      ['Plate not read in ' fileList(i).name]
      pause();
    end
  end
  
  % Wait for user to press a key
  %pause();
  
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
