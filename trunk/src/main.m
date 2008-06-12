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
noOf7CharsRead = 0;
noOf6CharsRead = 0;
noOf5CharsRead = 0;
noOf4CharsRead = 0;
noOf3CharsRead = 0;
noOf2CharsRead = 0;
noOf1CharsRead = 0;
noOf0CharsRead = 0;

% for syntax analysis: how far down the hitlist can the syntax analysis
% go to find the right char?
maxHitNo = 5;

% for holding plates where separation failed
sepErrs = '';

% the number of times each hit is used
hitsUsed = zeros(maxHitNo,1);
correctHits = zeros(maxHitNo,1);
%percentageOfHitsUsed = zeros(maxHitNo,1);

% for saving char images
charImgNo = 1;

% for statistics on how good we are on numbers and chars
legalChars = '0123456789ABCDEHJKLMNOPRSTUVXYZ';
noOfChars = zeros(size(legalChars,2),1);
noOfCharsRead = zeros(size(legalChars,2),1);
noCharCandidate = zeros(7,1);

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
%fileList = dir([imagesFolder '*.jpg']);
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

  ['Looking at image ' int2str(i) ' of ' int2str(noOfImages) '.' ]


  % Get plate coordinates from filename
  % xMin, xMax, yMin, yMax
  % Real Plate Coordinates = RPC
  RPC = [str2num(fileList(i).name(1,3:6)), str2num(fileList(i).name(1,8:11)), ...
                     str2num(fileList(i).name(1,13:16)), str2num(fileList(i).name(1,18:21))];


  % For testing:
   plateCoords = [0 0 0 0];



  % Analyze image and get coordinates of plate
  % plateCoords = detect_lines([imagesFolder fileList(i).name]);
 
  % plateCoords = detect2([imagesFolder fileList(i).name])
  % plateCoords = detect3([imagesFolder fileList(i).name])
 
  % High contrast
  % plateCoords = detect4([imagesFolder fileList(i).name])
   
  % plateCoords = histo_detect([imagesFolder fileList(i).name], freqTable);


  % Filter avg. intensity for neighbourhood 
  %plateCoords = DetectContrastAvg([imagesFolder fileList(i).name])

  % Besed on sameness
  %plateCoords = DetectSameness([imagesFolder fileList(i).name])

  % Frequency analysis
  %plateCoords = DetectPlateness([imagesFolder fileList(i).name]);

  % Contrast stretch on blocks
  %plateCoords = DetectCStretch([imagesFolder fileList(i).name]);

  % Distribution of intensities
  % plateCoords = DetectIntDist([imagesFolder fileList(i).name]);

  % Cut down number of colors in image
  % plateCoords = SaneCoords(DetectQuant([imagesFolder fileList(i).name]));

  % plateCoords = DetectNAME([imagesFolder fileList(i).name]);


  % All methods together
  %plateCoords = SaneCoords(DetectMain([imagesFolder fileList(i).name]));

  % Determine if plate is within found coordinates 
  if (RPC(1) >= plateCoords(1) && RPC(2) <= plateCoords(2) && ...
   RPC(3) >= plateCoords(3) && RPC(4) <= plateCoords(4))
    noOfPlatesFound = noOfPlatesFound + 1;
    plateFound = true;
  else
    % Echo name of image where plate was not found
    ['Plate not found in ' fileList(i).name]
    plateFound = false;
    

    % No candidate was found
    if sum(plateCoords) == 0
      noCandidate = noCandidate + 1;
    else
      % Pause when wrong plate was returned
      % Dont pause if no candidate was returned 
      %beep 
      %pause();
    end
    
  end   

  % For testing
  plateFound = true;

  
  % only try to rotate, segment and read plate if candidate was correct
  if plateFound
    
    % For testing:
    plateCoords(1) = RPC(1) - 10;
    plateCoords(2) = RPC(2) + 10;
    plateCoords(3) = RPC(3) - 10;
    plateCoords(4) = RPC(4) + 10;
    
    plateCoords = SaneCoords(plateCoords);
    
    realChars = [fileList(i).name(1,23), fileList(i).name(1,24), ...
        fileList(i).name(1,25), fileList(i).name(1,26), ...
        fileList(i).name(1,27), fileList(i).name(1,28), ...
        fileList(i).name(1,29)]

    %%%%%%%%%%
    % ROTATE %
    %%%%%%%%%%

    [rotatedPlateImg, newPlateCoords] = RotatePlateRadon([imagesFolder fileList(i).name],plateCoords,false);
    %newPlateCoords
    
    %%%%%%%%%%%%%%%%%
    % SEGMENT CHARS %
    %%%%%%%%%%%%%%%%%

    foundChars = 0;
    %[chars, charCoords, foundChars] = CharSeparationCC(rotatedPlateImg,newPlateCoords,true);
    [chars, charCoords, foundChars] = CharSeparationPTV(rotatedPlateImg,newPlateCoords,true);
    %charCoords
    
    %%%%%% Determine if found chars contains coordinates of real chars.%%%%
    if foundChars == 7
      
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
          
        end
      end

      % determine if the plate is correctly read
      if charsSegmented == 7
        noOfPlatesSegmented = noOfPlatesSegmented + 1;
        
      else
        ['Plate not segmented in ' fileList(i).name]
        sepErrs = strcat(sepErrs,realChars,',');
        %beep;
        %pause();
      end
    else
      ['Plate not segmented in ' fileList(i).name]
      sepErrs = strcat(sepErrs,realChars, ',');
      %beep;
      %pause();
    end

    %%%%%%%%%%%%%%%%%%%%%%
    % RECOGNIZE PATTERNS %
    %%%%%%%%%%%%%%%%%%%%%%
    
    plateAsString = '';
    
    if foundChars == 7
    %if foundChars == 7 && charsSegmented == 7
      [charHitLists, distances] = ReadPlateFV(chars,25);
      %[charHitLists, sums] = ReadPlateSUM(chars,5);
      plateAsString = [charHitLists(1,1) charHitLists(2,1) ...
        charHitLists(3,1) charHitLists(4,1) charHitLists(5,1) ...
        charHitLists(6,1) charHitLists(7,1)];
      %plateAsString = ReadPlateAND(chars,10)
    end
    

    if ~strcmp(plateAsString,'')
      
      %%%%%%%%%%%%%%%%%%%
      % SYNTAX ANALYSIS %
      %%%%%%%%%%%%%%%%%%%

      [plateAsString, hits] = SyntaxAnalysis(charHitLists,distances,maxHitNo)
      %[plateAsString, hits] = SyntaxAnalysis(charHitLists,sums,maxHitNo)
      
      plateCharsRead = 0;
      for f = 1:7
        % increment the no. of each char in plate
        charIndex = find(legalChars == realChars(f),1);
        noOfChars(charIndex) = noOfChars(charIndex) + 1;
        
        % check if chars are read correct
        if strcmp(plateAsString(f),realChars(f))
          plateCharsRead = plateCharsRead + 1;
          noOfCharsRead(charIndex) = noOfCharsRead(charIndex) + 1;
          if hits(f) <= maxHitNo
            correctHits(hits(f)) = correctHits(hits(f)) + 1;
          end
        else
          if strcmp(plateAsString(f),'_')
            noCharCandidate(f) = noCharCandidate(f) + 1;
          end
        end
      end
      
      % register if hole plate was read
      if plateCharsRead == 7
        noOf7CharsRead = noOf7CharsRead + 1;
      elseif plateCharsRead == 6
        noOf6CharsRead = noOf6CharsRead + 1;
      elseif plateCharsRead == 5
        noOf5CharsRead = noOf5CharsRead + 1;
      elseif plateCharsRead == 4
        noOf4CharsRead = noOf4CharsRead + 1;
      elseif plateCharsRead == 3
        noOf3CharsRead = noOf3CharsRead + 1;
      elseif plateCharsRead == 2
        noOf2CharsRead = noOf2CharsRead + 1;
      elseif plateCharsRead == 1
        noOf1CharsRead = noOf1CharsRead + 1;
      elseif plateCharsRead == 0
        noOf0CharsRead = noOf0CharsRead + 1;
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
percentageOfPlatesSegmentedAllPlates = noOfPlatesSegmented*(100/noOfPlatesFound)
percentageOfPlatesSegmentedAllImgs = noOfPlatesSegmented*(100/noOfImages)

%avgPlateness = round(platenessSum/noOfImages)
%avgPlatenessPixel = platenessSum/plateWidthSum    

% What was the shortest white line in a plate in percent
%shortestWhiteLine

%minIntDiff

noOfImages
noOfPlatesFound

if noOfPlatesSegmented == 0
  noOfPlatesSegmented = noOfImages
end

noOfPlatesSegmented
noOfPlatesRead

legalChars
percentageOfCharsRead = 100*(noOfCharsRead ./ noOfChars)
percentageOfCharsReadAllChars = 100*(sum(noOfCharsRead)/sum(noOfChars))
percentageOfDigitsRead = 100*(sum(noOfCharsRead(1:10))/sum(noOfChars(1:10)))
percentageOfLettersRead = 100*(sum(noOfCharsRead(11:31))/sum(noOfChars(11:31)))

% plate read stats
%percentageOfPlatesReadAllPlates = noOfPlatesRead*(100/noOfPlatesFound)
percentageOf7CharsReadAllImgs = noOf7CharsRead*(100/noOfImages)
percentageOf6CharsReadAllImgs = noOf6CharsRead*(100/noOfImages)
percentageOf5CharsReadAllImgs = noOf5CharsRead*(100/noOfImages)
percentageOf4CharsReadAllImgs = noOf4CharsRead*(100/noOfImages)
percentageOf3CharsReadAllImgs = noOf3CharsRead*(100/noOfImages)
percentageOf2CharsReadAllImgs = noOf2CharsRead*(100/noOfImages)
percentageOf1CharsReadAllImgs = noOf1CharsRead*(100/noOfImages)
percentageOf0CharsReadAllImgs = noOf0CharsRead*(100/noOfImages)

% output separation errors
sepErrs


% echo time
datestr(now)

