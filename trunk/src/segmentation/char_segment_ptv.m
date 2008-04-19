% Function to pick out the chars of a licenseplate in an image using
% peak-to-valley info. Plate must be located and rotated so it is
% placed horizontally in the image. The function returns the cut-out chars
% and a count on how many chars that have been found.
% 
% Input parameters:
% - plateImg: image of a licenseplate where the plate has (possibly) been
%   rotated so the plate is horizontal in the image.
% - figuresOn: true/false whether figures should be printed.
% 
% Output parameters:
% - chars: 
% - charCoords: 
% - foundChars: 
function [chars, charCoords, foundChars] = char_segment_ptv (plateImg, figuresOn) 

  chars.field1 = zeros(1,1);
  chars.field2 = zeros(1,1);
  chars.field3 = zeros(1,1);
  chars.field4 = zeros(1,1);
  chars.field5 = zeros(1,1);
  chars.field6 = zeros(1,1);
  chars.field7 = zeros(1,1);
  charCoords = zeros(7,4);
  foundChars = 0;
  
  % display image
  %if figuresOn
  %  figure(2), subplot(3,1,1), imshow(plateImg), title('plateImg');
  %end
  
  % transform image to binary and show the binary image
  %%%%%%%%%%%% TO-DO: determine level. In LicensplateSydney.pdf level is
  %%%%%%%%%%%% based on the average gray scale value of the 100 pixels with
  %%%%%%%%%%%% the largest gradient. Do we need that?
  %level = graythresh(img);
  %level = 0.6;
  %bwImg = im2bw(plateImg,level);
  %bwImg = im2bw(plateImg);
  
  % display binary image
  %figure(1), subplot(6,4,5:8), imshow(bwImg), title('bwImg');
  
  % create grayscale image
  grayImg = rgb2gray(plateImg);

  % calculate width and height of image
  imHeight = size(plateImg,1)
  imWidth = size(plateImg,2)
  middle = round(imHeight / 2)
  
  %%%%%%%%%%%%% TO-DO: Filtering or watersheding? %%%%%%%%%%%%%%%%
  
  %%%%% Experiments: TOP AND BOTTOM HAT %%%%%%%%
  %se = strel('disk', 15);
  %imgTophat = imtophat(grayImg, se);
  %imgBothat = imbothat(grayImg, se);
  %figure(2), subplot(8,4,5:8), imshow(imgTophat, []), title('top-hat image');
  %figure(2), subplot(8,4,9:12), imshow(imgBothat, []), title('bottom-hat image');
  
  %imgContrastEnh = imsubtract(imadd(imgTophat, grayImg), imgBothat);
  
  %figure(2), subplot(8,4,13:16), imshow(imgContrastEnh), title('original + top-hat - bottom-hat');
  
  % is this necessary??
  %Iec = imcomplement(Ienhance);
  %figure(2), subplot(4,1,4), imshow(Iec), title('complement of enhanced image');
  
  %%%%% Enhance brightness and negate %%%%%%%%
  brightGrayImg = uint8((double(grayImg)/180)*255);
  
  % negate grayimg
  %grayImg = uint8(abs(double(grayImg)-255));
  
  %imgContrastEnh = im2bw(grayImg,graythresh(grayImg));
  %if figuresOn
  %  figure(22), imshow(grayImg), title('brigtnessEnh image');
  %  %figure(2), subplot(8,4,9:12), imshow(imgContrastEnh), title('brigtnessEnh bw image');
  %  hold on;
  %end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %%%%                                 %%%%
  %%%% GET SIGNATURES ACROSS SCANLINES %%%%
  %%%%                                 %%%%
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  % REPLACE WITH GETSIGNATURE
  
  summedScanlines = zeros(1,imWidth);
  
  % sum up scanlines: entire image
  for i = 1:imHeight
    summedScanlines = summedScanlines + double(brightGrayImg(i,:));
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %%%%                          %%%%
  %%%% PEAK TO VALLEY ANALYSING %%%%
  %%%%                          %%%%
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  % smoothen with simple average function
  lagSize = 6;
  for i = 1:imWidth
    
    % determine the low and high for calculating mean
    low = i-lagSize+1;
    high = i+lagSize;
    
    if low < 1
      low = 1;
    end
    if high > imWidth
      high = imWidth;
    end
    
    summedScanlines(i) = mean(summedScanlines(low:high));
  end
  
  % find peaks: where to cut
  allPeaks = zeros(8,2);
  p = 1;
  goingDown = false;
  %minInterval = imWidth / 15
  noOfNexts = 5
  
  % mark spots where the next spot has a higher value
  for i = 1:imWidth-noOfNexts % MAYBE THIS IS NOT GOOD? :)
    %current = summedScanlines(i);
    
    
    next = zeros(noOfNexts+1,1); % plus 1 to hold current
    for n = 0:noOfNexts-1
      next(n+1) = summedScanlines(i+n);
    end
    
    % going up: searching for peaks
    if ~goingDown
      
      % determine if the next pixels indicate that the current spot is a
      % peak
      %peakReached = false;
      for n = 1:noOfNexts-1
        if next(n) > next(n+1)
          peakReached = true;
        else
          peakReached = false;
          break;
        end
      end
      
      % if theres a peak: register it 
      %if p == 1 || (current > allPeaks(p-1,1) + minInterval)
      if peakReached
        allPeaks(p,1) = i;
        allPeaks(p,2) = next(1);
        %previous = current;
        p = p + 1;
        goingDown = true;
      end

    
    % going down: searching for valley, when valley found: start going up
    elseif goingDown && next(2) > next(1)
      goingDown = false;
    end
    
  end
  
  % return if not enough peaks has been found
  if size(allPeaks) < 8
    return;
  end
  
  % find the 8 maximum peaks
  peaks = zeros(8,1);
  
  for p = 1:8
    [maxVal,maxPos] = max(allPeaks(:,2));
    peaks(p) = allPeaks(maxPos,1);
    allPeaks(maxPos,2) = 0;
  end
  
  peaks
  
  % plot summedScanlines and found peaks
  if figuresOn
    normSummedScanlines = (summedScanlines/max(summedScanlines))*imHeight;
    figure(22), subplot(6,3,1:3), imshow(grayImg), title('gray image');
    figure(22), subplot(6,3,4:6), imshow(brightGrayImg), title('brigtnessEnh image');
    hold on;
    plot(normSummedScanlines,'r');
    for j = 1:size(allPeaks)
      plot(allPeaks(j), middle, 'gx');
    end
    for i = 1:8
      plot(peaks(i), 1:imHeight, 'b-');
    end
    hold off;
  end
 
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %%%%                          %%%%
  %%%% PEAK TO VALLEY ANALYSING %%%%
  %%%%                          %%%%
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  %{
  % REPLACE WITH GETSIGNATURE
  
  summedScanlines = zeros(imHeight,1);
  size(summedScanlines)
  size(brightGrayImg)
  
  % sum up scanlines: entire image
  for i = 1:imWidth
    summedScanlines = summedScanlines + double(brightGrayImg(:,i));
  end
  
  % smoothen with simple average function
  lagSize = 15
  for i = 1:imHeight
    
    % determine the low and high for calculating mean
    low = i-lagSize+1;
    high = i+lagSize;
    
    if low < 1
      low = 1;
    end
    if high > imHeight
      high = imHeight;
    end
    
    summedScanlines(i) = mean(summedScanlines(low:high));
  end
  
  %}

  
  %%%% Find upper and lower cut-line %%%%
  
  % use bw img to find upper and lower cut
  bwImg = im2bw(grayImg,graythresh(grayImg));
  %brightBwImg = im2bw(brightGrayImg,graythresh(brightGrayImg));
  
  if figuresOn
    %normSummedScanlines = (summedScanlines/max(summedScanlines))*imWidth;
    figure(22), subplot(6,3,7:9), imshow(bwImg), title('bw from grayImg');
    %figure(22), subplot(4,1,4), imshow(brightBwImg), title('bw from brightGrayImg');
    %hold on;
    %figure(33), plot(normSummedScanlines,'r');
    %hold off;
  end

  % find top- and bottom cuts
  scanlineSums = sum(bwImg,2);
  bottomSums = scanlineSums(1:middle,:);
  topSums = scanlineSums(middle:imHeight,:);
  [maxBottom,lowerCut] = max(bottomSums)
  [maxTop,upperCut] = max(topSums);
  upperCut = upperCut + middle
  
    
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %%%%                       %%%%
  %%%% CUT AND RETURN CHARS  %%%%
  %%%%                       %%%%
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  foundChars = 7;
  
  % for removing white spaces
  charHeight = upperCut - lowerCut + 1

  % cut out chars, roughly
  plotPos = 10;
  for n = 1:7
    
    % find x-coordinates using peaks
    [xMin, minIndex] = min(peaks)
    peaks(minIndex) = inf;
    [xMax, maxIndex] = min(peaks)
    
    % adjust coordinates if they point outside the image
    if xMin < 1
      xMin = 1;
    end
    if xMax > imWidth
      xMax = imWidth;
    end
    %if yMin < 1
    %  yMin = 1;
    %end
    %if yMax > imHeight
    %  yMax = imHeight;
    %end
    
    % remove white spaces on both sides of char
    %leftWhite = xMin;
    %rightWhite = xMax;
    %sum(bwImg(lowerCut:upperCut,xMin))
    while sum(bwImg(lowerCut:upperCut,xMin)) == charHeight && xMin < xMax
      xMin = xMin + 1;
    end
    while sum(bwImg(lowerCut:upperCut,xMax)) == charHeight && xMin < xMax
      xMax = xMax - 1;
    end
    
    %leftWhite
    %rightWhite
    
    % specify position of char
    fieldName = strcat('field',int2str(n));
    %chars.(fieldName) = plateImg(upperCut:lowerCut,xMin:xMax,:);
    chars.(fieldName) = bwImg(lowerCut:upperCut,xMin:xMax);
    charCoords(n,1) = xMin;
    charCoords(n,2) = xMax;
    charCoords(n,3) = lowerCut;
    charCoords(n,4) = upperCut;
    
    % display char
    if figuresOn
      figure(22), subplot(6,3,plotPos), imshow(chars.(fieldName)), title(fieldName);
      plotPos = plotPos + 1;
    end
  end  
  
end