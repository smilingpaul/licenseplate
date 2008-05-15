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
noOfPlatesSegmented = 0;
noOfPlatesRead = 0;
%percentageOfPlatesFound = 0;
%percentageOfPlatesSegmented = 0;
%percentageOfPlatesRead = 0;
%percentageOfCharsRead = 0;
noOfChar1sRead = 0;
noOfChar2sRead = 0;
noOfChar3sRead = 0;
noOfChar4sRead = 0;
noOfChar5sRead = 0;
noOfChar6sRead = 0;
noOfChar7sRead = 0;
noChar1Candidate = 0;
noChar2Candidate = 0;
noChar3Candidate = 0;
noChar4Candidate = 0;
noChar5Candidate = 0;
noChar6Candidate = 0;
noChar7Candidate = 0;
%percentageOfChar1sRead = 0;
%percentageOfChar2sRead = 0;
%percentageOfChar3sRead = 0;
%percentageOfChar4sRead = 0;
%percentageOfChar5sRead = 0;
%percentageOfChar6sRead = 0;
%percentageOfChar7sRead = 0;

% for syntax analysis: how far down in the hitlist can the syntax analysis
% go to find the right char
maxHitNo = 6;

% the number of times each hit is used
hitsUsed = zeros(maxHitNo,1);
percentageOfHitsUsed = zeros(maxHitNo,1);

% for saving char images
charImgNo = 1;

% Number of times there weas no candidate

% For getting avg plateness
platenessSum = 0;
plateWidthSum = 0;

% Number of times there was no candidate
noCandidate = 0;

% Analyzing lengths of white lines in plates
shortestWhiteLine = inf;

% Minimal difference between max and min intensity in plates
%minIntDiff = inf;

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

  ['Looking at image ' int2str(i) ' of ' int2str(noOfImages) '.' ]


  % Get plate coordinates from filename
  % xMin, xMax, yMin, yMax
  % Real Plate Coordinates = RPC
  RPC = [str2num(fileList(i).name(1,3:6)), str2num(fileList(i).name(1,8:11)), ...
                     str2num(fileList(i).name(1,13:16)), str2num(fileList(i).name(1,18:21))];
 
  
  % Calculate plateness for this plate
  %image = imresize(rgb2gray(imread([imagesFolder fileList(i).name])),0.25);
  %RPC = RPC * 0.25;
  %platenessSum = platenessSum + GetPlateness(GetSignature(image(RPC(3):RPC(4), RPC(1):RPC(2)), 0));
  %plateWidthSum = plateWidthSum + (RPC(2)-RPC(1)); 
  %plateCoords = [ 0 0 0 0 ];
  

  % Show plate
  % Read image from file
  %image = rgb2gray(imread([imagesFolder fileList(i).name]));
  %image = log10(double(image));
  %image = image(RPC(3)-30:RPC(4)+30, RPC(1)-30:RPC(2)+30);
  %image = imresize(image, 0.25);
  %[ below, above ] = GetDistribution(image)
  
  % Find shortest white line in plate
  %linePerc = GetLongestLine(image);
  %if linePerc < shortestWhiteLine
  %  shortestWhiteLine = linePerc
  %  beep;
  %  pause;
  %end


  % For testing:
  plateCoords = [0 0 0 0];


  %image = image(1:16,1:16);
  %figure(100), imshow(image);
  %figure(101), hist(double(image(:)),256);

  %thisIntDiff = max(max(image)) - min(min(image));  
  %if thisIntDiff < minIntDiff
  %  minIntDiff = thisIntDiff;
  %end



  % Analyze image and get coordinates of plate
  %plateCoords = detect_lines([imagesFolder fileList(i).name]);
 
  %plateCoords = detect2([imagesFolder fileList(i).name])
  %plateCoords = detect3([imagesFolder fileList(i).name])
 
  % High contrast
  % plateCoords = detect4([imagesFolder fileList(i).name])
   
  % plateCoords = histo_detect([imagesFolder fileList(i).name], freqTable);


  % Filter avg. intensity for neighbourhood 
  % 62.7/85.0 -> 63.9/90.6
  %plateCoords = DetectContrastAvg([imagesFolder fileList(i).name])

  % Besed on sameness 56.8/95.5 -> whiteline 56.6/95.8
  % plateCoords = DetectSameness([imagesFolder fileList(i).name])

  
  % Frequency analysis 50.5/65.5 -> whiteline 52.8/72.0
  % plateCoords = DetectPlateness([imagesFolder fileList(i).name]);

  % Contrast stretch on blocks
  % plateCoords = DetectCStretch([imagesFolder fileList(i).name]);

  % Distribution of intensities
  %plateCoords = DetectIntDist([imagesFolder fileList(i).name]);

  % 67.8/75.4 -> whiteline 73.5/85.4
  % plateCoords = DetectQuant([imagesFolder fileList(i).name]);



  %plateCoords = DetectNAME([imagesFolder fileList(i).name]);


  % All methods together
   plateCoords = DetectMain([imagesFolder fileList(i).name]);

  % Determine if plate is within found coordinates 
  if (RPC(1) >= plateCoords(1) && RPC(2) <= plateCoords(2) && ...
   RPC(3) >= plateCoords(3) && RPC(4) <= plateCoords(4))
    noOfPlatesFound = noOfPlatesFound + 1;
    plateFound = true;
  else
    % Echo name of image where plate was not found
    ['Plate not found in ' fileList(i).name]
    plateFound = false;
    %beep 
    %pause(); % Pause when plate was not found 

    % No candidate was found
    if sum(plateCoords) == 0
      noCandidate = noCandidate + 1;
    end
  end   

  % For testing
  %plateFound = true;
  
  % only try to rotate, segment and read plate if candidate was correct
  if plateFound
    
    % For testing:
    %plateCoords(1) = RPC(1) - 15;
    %plateCoords(2) = RPC(2) + 15;
    %plateCoords(3) = RPC(3) - 15;
    %plateCoords(4) = RPC(4) + 15;

    %%%%%%%%%%
    % ROTATE %
    %%%%%%%%%%

    [rotatedPlateImg, newPlateCoords] = plate_rotate_radon([imagesFolder fileList(i).name],plateCoords,false);
    %newPlateCoords
    
    %%%%%%%%%%%%%%%%%
    % SEGMENT CHARS %
    %%%%%%%%%%%%%%%%%

    foundChars = 0;
    [chars, charCoords, foundChars] = char_segment_cc(rotatedPlateImg,newPlateCoords,false);
    %[chars, charCoords, foundChars] = char_segment_ptv(rotatedPlateImg,newPlateCoords,true);
    %charCoords
    %%%%%% Determine if found chars contains coordinates of real chars. %%%%%
    %figure(19), imshow(imread([imagesFolder fileList(i).name]));
    
    
    if foundChars == 7
      
      %{

      % OLD METHOD: CALCULATE CHAR COORDS
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
      
      %}
      
      % NEW METHOD: CHAR MIDDLES ARE SIMPLY WITHIN PLATE
      
      % calculate newRealPlateCoords
      if plateCoords(1) ~= newPlateCoords(1) || ...
          plateCoords(2) ~= newPlateCoords(2) || ...
          plateCoords(3) ~= newPlateCoords(3) || ...
          plateCoords(4) ~= newPlateCoords(4)
        coordDif = newPlateCoords - plateCoords;
        newRealPlateCoords = RPC + coordDif;
      else
        newRealPlateCoords = RPC;
      end
      
      charsSegmented = 0;
      for c = 1:7
        charMiddle = [round((charCoords(c,1)+charCoords(c,2))/2), ...
          round((charCoords(c,3)+charCoords(c,4))/2)];
        if charMiddle(1) >= newRealPlateCoords(1) && ...
            charMiddle(1) <= newRealPlateCoords(2) && ...
            charMiddle(2) >= newRealPlateCoords(3) && ...
            charMiddle(2) <= newRealPlateCoords(4)
          charsSegmented = charsSegmented + 1;
          
          %if c < 7
          %  round((charCoords(c+1,1)+charCoords(c+1,2))/2) - ...
          %  charMiddle(1)
          %end
          
        end
      end

      % determine if the plate is correctly read
      if charsSegmented == 7
        noOfPlatesSegmented = noOfPlatesSegmented + 1;
        
        % for pattern recognition: save images
        %for n = 1:7
        %  charName = strcat('char',int2str(n));
        %  posFolderName = strcat('pos',int2str(n));
        %  imgName = strcat(imagesFolder, ...
        %    posFolderName,'/',int2str(charImgNo),'.PNG');
        %  imwrite (chars.(charName),imgName,'png','BitDepth',1);
        %  charImgNo = charImgNo + 1;
        %end
        
      else
        ['Plate not segmented in ' fileList(i).name]
        %pause();
      end
    else
      ['Plate not segmented in ' fileList(i).name]
      %pause();
    end

    %%%%%%%%%%%%%%%%%%%%%%
    % RECOGNIZE PATTERNS %
    %%%%%%%%%%%%%%%%%%%%%%
    
    plateAsString = '';
    if foundChars == 7 && charsSegmented == 7
      [charHitLists, distances] = ReadPlateFV(chars,5,3);
      plateAsString = [charHitLists(1,1) charHitLists(2,1) ...
        charHitLists(3,1) charHitLists(4,1) charHitLists(5,1) ...
        charHitLists(6,1) charHitLists(7,1)]
    end

    if ~strcmp(plateAsString,'')
      
      %%%%%%%%%%%%%%%%%%%
      % SYNTAX ANALYSIS %
      %%%%%%%%%%%%%%%%%%%

      [plateAsString, hits] = SyntaxAnalysis(charHitLists,distances,maxHitNo)

      realChars = [fileList(i).name(1,23), fileList(i).name(1,24), ...
        fileList(i).name(1,25), fileList(i).name(1,26), ...
        fileList(i).name(1,27), fileList(i).name(1,28), ...
        fileList(i).name(1,29)]
      
      % check if the chars are read correct. TO-DO: do with matrix == less
      % code
      
      plateRead = true;
      if strcmp(plateAsString(1),realChars(1))
        noOfChar1sRead = noOfChar1sRead + 1;
      else
        plateRead = false;
        if strcmp(plateAsString(1),'_')
          noChar1Candidate = noChar1Candidate + 1;
        end
        %distances(1,hits(1))
        %pause;
      end
      if strcmp(plateAsString(2),realChars(2))
        noOfChar2sRead = noOfChar2sRead + 1;
      else
        plateRead = false;
        if strcmp(plateAsString(2),'_')
          noChar2Candidate = noChar2Candidate + 1;
        end
        %distances(2,hits(2))
        %pause;
      end
      if strcmp(plateAsString(3),realChars(3))
        noOfChar3sRead = noOfChar3sRead + 1;
      else
        plateRead = false;
        if strcmp(plateAsString(3),'_')
          noChar3Candidate = noChar3Candidate + 1;
        end
        %distances(3,hits(3))
        %pause;
      end
      if strcmp(plateAsString(4),realChars(4))
        noOfChar4sRead = noOfChar4sRead + 1;
      else
        plateRead = false;
        if strcmp(plateAsString(4),'_')
          noChar4Candidate = noChar4Candidate + 1;
        end
        %distances(4,hits(4))
        %pause;
      end
      if strcmp(plateAsString(5),realChars(5))
        noOfChar5sRead = noOfChar5sRead + 1;
      else
        plateRead = false;
        if strcmp(plateAsString(5),'_')
          noChar5Candidate = noChar5Candidate + 1;
        end
        %distances(5,hits(5))
        %pause;
      end
      if strcmp(plateAsString(6),realChars(6))
        noOfChar6sRead = noOfChar6sRead + 1;
      else
        plateRead = false;
        if strcmp(plateAsString(6),'_')
          noChar6Candidate = noChar6Candidate + 1;
        end
        %distances(6,hits(6))
        %pause;
      end
      if strcmp(plateAsString(7),realChars(7))
        noOfChar7sRead = noOfChar7sRead + 1;
      else
        plateRead = false;
        if strcmp(plateAsString(7),'_')
          noChar7Candidate = noChar7Candidate + 1;
        end
        %distances(7,hits(7))
        %pause;
      end
      
      % register if hole plate was read
      if plateRead
        noOfPlatesRead = noOfPlatesRead + 1;
      end
      
      % register which hits have been used
      for h = 1:7
        if hits(h) <= maxHitNo
          hitsUsed(hits(h)) = hitsUsed(hits(h)) + 1;
        end
      end
    
    end

  end % plateFound
  
  % Wait for user to press a key after every image
  %pause();
  
end % iterate through images

%%%%%%%%%%%%%%%
% PRINT STATS %
%%%%%%%%%%%%%%%

percentageOfPlatesFound = noOfPlatesFound*(100/noOfImages)

% What percentage of the candidates were correct
correctnessOfCandidates = noOfPlatesFound*(100/(noOfImages-noCandidate))

%noOfPlatesNotFound = noOfImages - noOfPlatesFound
percentageOfPlatesSegmented = noOfPlatesSegmented*(100/noOfPlatesFound)
%percentageOfPlatesSegmented = noOfPlatesSegmented*(100/noOfImages)

%avgPlateness = round(platenessSum/noOfImages)
%avgPlatenessPixel = platenessSum/plateWidthSum    

% What was the shortest white line in a plate in percent
%shortestWhiteLine

%minIntDiff

if noOfPlatesSegmented == 0
  noOfPlatesSegmented = noOfImages
end

noOfImages
noOfPlatesFound
noOfPlatesSegmented
noOfPlatesRead

percentageOfPlatesReadAllPlates = noOfPlatesRead*(100/noOfPlatesFound)
percentageOfPlatesReadAllImgs = noOfPlatesRead*(100/noOfImages)

percentageOfChar1sReadAllImgs = noOfChar1sRead*(100/(noOfImages))
percentageOfChar2sReadAllImgs = noOfChar2sRead*(100/(noOfImages))
percentageOfChar3sReadAllImgs = noOfChar3sRead*(100/(noOfImages))
percentageOfChar4sReadAllImgs = noOfChar4sRead*(100/(noOfImages))
percentageOfChar5sReadAllImgs = noOfChar5sRead*(100/(noOfImages))
percentageOfChar6sReadAllImgs = noOfChar6sRead*(100/(noOfImages))
percentageOfChar7sReadAllImgs = noOfChar7sRead*(100/(noOfImages))

correctnessOfChar1sReadAllImgs = noOfChar1sRead*(100/(noOfImages-noChar1Candidate))
correctnessOfChar2sReadAllImgs = noOfChar2sRead*(100/(noOfImages-noChar2Candidate))
correctnessOfChar3sReadAllImgs = noOfChar3sRead*(100/(noOfImages-noChar3Candidate))
correctnessOfChar4sReadAllImgs = noOfChar4sRead*(100/(noOfImages-noChar4Candidate))
correctnessOfChar5sReadAllImgs = noOfChar5sRead*(100/(noOfImages-noChar5Candidate))
correctnessOfChar6sReadAllImgs = noOfChar6sRead*(100/(noOfImages-noChar6Candidate))
correctnessOfChar7sReadAllImgs = noOfChar7sRead*(100/(noOfImages-noChar7Candidate))

percentageOfChar1sReadAllPlates = noOfChar1sRead*(100/(noOfPlatesFound))
percentageOfChar2sReadAllPlates = noOfChar2sRead*(100/(noOfPlatesFound))
percentageOfChar3sReadAllPlates = noOfChar3sRead*(100/(noOfPlatesFound))
percentageOfChar4sReadAllPlates = noOfChar4sRead*(100/(noOfPlatesFound))
percentageOfChar5sReadAllPlates = noOfChar5sRead*(100/(noOfPlatesFound))
percentageOfChar6sReadAllPlates = noOfChar6sRead*(100/(noOfPlatesFound))
percentageOfChar7sReadAllPlates = noOfChar7sRead*(100/(noOfPlatesFound))

correctnessOfChar1sReadAllPlates = noOfChar1sRead*(100/(noOfPlatesFound-noChar1Candidate))
correctnessOfChar2sReadAllPlates = noOfChar2sRead*(100/(noOfPlatesFound-noChar2Candidate))
correctnessOfChar3sReadAllPlates = noOfChar3sRead*(100/(noOfPlatesFound-noChar3Candidate))
correctnessOfChar4sReadAllPlates = noOfChar4sRead*(100/(noOfPlatesFound-noChar4Candidate))
correctnessOfChar5sReadAllPlates = noOfChar5sRead*(100/(noOfPlatesFound-noChar5Candidate))
correctnessOfChar6sReadAllPlates = noOfChar6sRead*(100/(noOfPlatesFound-noChar6Candidate))
correctnessOfChar7sReadAllPlates = noOfChar7sRead*(100/(noOfPlatesFound-noChar7Candidate))

percentageOfChar1sReadSegmentedPlates = noOfChar1sRead*(100/(noOfPlatesSegmented))
percentageOfChar2sReadSegmentedPlates = noOfChar2sRead*(100/(noOfPlatesSegmented))
percentageOfChar3sReadSegmentedPlates = noOfChar3sRead*(100/(noOfPlatesSegmented))
percentageOfChar4sReadSegmentedPlates = noOfChar4sRead*(100/(noOfPlatesSegmented))
percentageOfChar5sReadSegmentedPlates = noOfChar5sRead*(100/(noOfPlatesSegmented))
percentageOfChar6sReadSegmentedPlates = noOfChar6sRead*(100/(noOfPlatesSegmented))
percentageOfChar7sReadSegmentedPlates = noOfChar7sRead*(100/(noOfPlatesSegmented))

correctnessOfChar1sReadSegmentedPlates = noOfChar1sRead*(100/(noOfPlatesSegmented-noChar1Candidate))
correctnessOfChar2sReadSegmentedPlates = noOfChar2sRead*(100/(noOfPlatesSegmented-noChar2Candidate))
correctnessOfChar3sReadSegmentedPlates = noOfChar3sRead*(100/(noOfPlatesSegmented-noChar3Candidate))
correctnessOfChar4sReadSegmentedPlates = noOfChar4sRead*(100/(noOfPlatesSegmented-noChar4Candidate))
correctnessOfChar5sReadSegmentedPlates = noOfChar5sRead*(100/(noOfPlatesSegmented-noChar5Candidate))
correctnessOfChar6sReadSegmentedPlates = noOfChar6sRead*(100/(noOfPlatesSegmented-noChar6Candidate))
correctnessOfChar7sReadSegmentedPlates = noOfChar7sRead*(100/(noOfPlatesSegmented-noChar7Candidate))

%hitsUsed

% calculate percentage of total hits used
totalNoCharCandidate = noChar1Candidate + noChar2Candidate + ...
  noChar3Candidate + noChar4Candidate + noChar5Candidate + ...
  noChar6Candidate + noChar7Candidate;
for h = 1:maxHitNo
  percentageOfHitsUsed(h) = hitsUsed(h)*(100/((noOfPlatesSegmented*7)-totalNoCharCandidate));
end
percentageOfHitsUsed

% echo time
datestr(now)

