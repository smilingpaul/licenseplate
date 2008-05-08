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
function [chars, charCoords, foundChars] = char_segment_ptv (plateImg, plateCoords, figuresOn) 

  %%%%%%%%%%%%%%%%%%
  % PRE-PROCESSING %
  %%%%%%%%%%%%%%%%%%
  
  % char height and - width
  defaultCharHeight = 8;
  defaultCharWidth = 5;
  %chars = zeros(defaultCharHeight,defaultCharWidth,7);

  % used for smoothing plate signature
  smoothFactor = 5;

  % create output elements
  chars.field1 = zeros(1,1);
  chars.field2 = zeros(1,1);
  chars.field3 = zeros(1,1);
  chars.field4 = zeros(1,1);
  chars.field5 = zeros(1,1);
  chars.field6 = zeros(1,1);
  chars.field7 = zeros(1,1);
  charCoords = zeros(7,4);
  foundChars = 0;
  
  % create grayscale plate image
  %plateImg = img(plateCoords(3):plateCoords(4), ...
  %  plateCoords(1)-smoothFactor:plateCoords(2)+smoothFactor-1,:);
  grayImg = rgb2gray(plateImg);

  % calculate width and height of image
  plateImgHeight = size(plateImg,1);
  plateImgWidth = size(plateImg,2);
  plateMiddle = round(plateImgHeight / 2);
  
  %%%%% Enhance brightness and contrast %%%%%%%%
  brightImg = uint8((double(grayImg)/mean(mean(grayImg)))*255);
  %brightImg = uint8((double(grayImg)/50)*255);
  contrastImg = ContrastStretch(brightImg,0);
  %contrastImg = ContrastStretch(grayImg,0);
  
  bwImg = im2bw(contrastImg,graythresh(contrastImg));
  %bwImg = im2bw(brightImg,graythresh(brightImg));
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % REMOVE COMPONENTS THAT MAY BE AREA OUTSIDE PLATE %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  %{
  [negBwImg, noOfComp] = bwlabel(~bwImg);
  
  if figuresOn
    figure(22), subplot(6,3,10:12), imshow(negBwImg), title('negbwimg');
  end
  
  for i = 1:noOfComp
    [y,x] = find(negBwImg == i);
    %plateImgWidth + (2*smoothFactor);
    %max(x) - min(x) + 1;
    if max(x) - min(x) + 1 == plateImgWidth
      % set color of pixels in component to black
      compSize = length(find(negBwImg == i));
      for j = 1:compSize
        negBwImg(y(j), x(j)) = 0;
      end
      break;
    end
  end
  
  %}
  
  %bwImg = ~negBwImg;
  bwImg = bwlabel(bwImg);
  %if figuresOn
  %  figure(22), subplot(6,3,13:15), imshow(bwImg), title('bwimg');
  %end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % GET SIGNATURES ACROSS SCANLINES %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  
  % collect info on every line
  %scanlines = zeros(plateImgHeight,plateImgWidth-(2*smoothFactor));
  %
  %scanlineAvgs = zeros(plateImgHeight,1);
  %
  %for i = 1:plateImgHeight
  %  %scanlines(i,:) = GetSignature(brightGrayImg(i,:),smoothFactor);
  %  scanlines(i,:) = GetSignature(bwImg(i,:),smoothFactor);
  %  scanlineAvgs(i) = mean(scanlines(i,:));
  %end
  %size(scanlines)
  
  %normScanlines = (scanlines/max(summedScanlines));
  
  % sum up lines
  summedScanlines = zeros(1,plateImgWidth);
  
  %summedScanlines = GetSignature(brightGrayImg,smoothFactor);
  
  % sum up scanlines: entire image
  for i = 1:plateImgHeight
    summedScanlines = summedScanlines + double(contrastImg(i,:));
  end
  
  %summedScanlines = GetSignature(brightGrayImg,smoothFactor);
  %summedScanlines = GetSignature(bwImg,smoothFactor);
  
  %figure(33), plot(summedScanlines);
  
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%
  % SMOOTHING OF SIGNATURE %
  %%%%%%%%%%%%%%%%%%%%%%%%%%
  
  % smoothen with simple average function:
  for i = 1:plateImgWidth
    
    % determine the first and last for calculating mean of current
    first = i-smoothFactor+1;
    last = i+smoothFactor;
    
    % correct first and last if they point outside plate image
    if first < 1
      first = 1;
    end
    if last > plateImgWidth
      last = plateImgWidth;
    end
    
    % calculate mean
    summedScanlines(i) = mean(summedScanlines(first:last));
  end
  
  % calculate average on summedScanlines
  %plateSigAvg = mean(summedScanlines);
  %normPlateSigAvg = (plateSigAvg/max(summedScanlines));
  
  %normSummedScanlines = (summedScanlines/max(summedScanlines));
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % FIND PEAKS: WHERE TO CUT %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  allPeaks = zeros(8,2); % pos. 1 holds index, 2 holds value (of peak)
  peakNo = 1;
  goingDown = false;
  noOfNexts = 5; % the no. of next spots that have to decrease in order for the current spot to be a peak
  
  % mark spots that are peaks
  for i = 1:size(summedScanlines,2)-noOfNexts % MAYBE THIS IS NOT GOOD? :)
    %current = summedScanlines(i);
    
    % initial
    nexts = zeros(noOfNexts+1,1); % plus 1 to hold current
    for n = 0:noOfNexts-1
      nexts(n+1) = summedScanlines(i+n);
    end
    
    % going up: searching for peaks
    if ~goingDown
      
      % determine if the next pixels indicate that the current spot is a
      % peak
      for n = 1:noOfNexts-1
        if nexts(n) > nexts(n+1)
          peakReached = true;
        else
          peakReached = false;
          break;
        end
      end
      
      % if theres a peak: register it
      if peakReached
        allPeaks(peakNo,1) = i;
        allPeaks(peakNo,2) = nexts(1);
        peakNo = peakNo + 1;
        goingDown = true;
      end
    
    % going down: searching for valley, when valley found: start going up
    elseif goingDown && nexts(2) > nexts(1)
      goingDown = false;
    end
    
  end
  
  % return if not enough peaks has been found
  if size(allPeaks) < 8
    return;
  end
  
  % find the 8 maximum peaks: the 8 places to cut
  % maxPeaks holds indexes of the 8 max peaks
  maxPeaks = zeros(8,1);
  
  for p = 1:8
    [maxPeak,maxPeakPos] = max(allPeaks(:,2));
    maxPeaks(p) = allPeaks(maxPeakPos,1);
    allPeaks(maxPeakPos,2) = 0;
  end
  
  % move peaks
  %allPeaks = allPeaks + smoothFactor;
  %peaks = peaks + smoothFactor;
  
  % display grayImg, brightImg and contrastImg
  % plot summedScanlines and found peaks
  if figuresOn
    normSummedScanlines = (summedScanlines/max(summedScanlines))*plateImgHeight;
    figure(22), subplot(7,3,1:3), imshow(grayImg), title('grayImg');
    figure(22), subplot(7,3,4:6), imshow(brightImg), title('brightImg');
    figure(22), subplot(7,3,7:9), imshow(contrastImg), title('contrastImg');
    %figure(65), imshow(contrastImg), title('contrastImg');
    hold on;
    plot(1:plateImgWidth, normSummedScanlines, 'r');
    for j = 1:size(allPeaks)
      plot(allPeaks(j), plateMiddle, 'gx');
    end
    for i = 1:8
      plot(maxPeaks(i), 1:plateImgHeight, 'b-');
    end
    hold off;
  end
 
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % PEAK TO VALLEY ANALYSING: TOP AND BOTTOM CUT %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  % REPLACE WITH GETSIGNATURE
  
  summedVertScanlines = zeros(plateImgHeight,1);
  
  % sum up scanlines: entire image
  for i = 1:plateImgWidth
    summedVertScanlines = summedVertScanlines + double(contrastImg(:,i));
    %summedVertScanlines = summedVertScanlines + double(bwImg(:,i));
  end
  
  % smoothen with simple average function
  lagSize = 10;
  for i = 1:plateImgHeight
    
    % determine the low and high for calculating mean
    low = i-lagSize+1;
    high = i+(lagSize*2); % we go further forward than backward because of the entering of the plate
    
    if low < 1
      low = 1;
    end
    if high > plateImgHeight
      high = plateImgHeight;
    end
    
    summedVertScanlines(i) = mean(summedVertScanlines(low:high));
  end
  
  meanish = mean(summedVertScanlines);
  
  %%%% Find upper and lower cut-line %%%%
  
  % use bw img to find upper and lower cut
  %bwImg = im2bw(grayImg,graythresh(grayImg));
  %brightBwImg = im2bw(brightGrayImg,graythresh(brightGrayImg));
  
  % find bottom and top cut
  lowerCut = 1;
  upperCut = 1;
  for i = 1:plateImgHeight-1
    if summedVertScanlines(i) < meanish && ...
        summedVertScanlines(i+1) > meanish
      lowerCut = i;
      break;
    end
  end
  
  for i = lowerCut:plateImgHeight-1
    if summedVertScanlines(i) > meanish && ...
        summedVertScanlines(i+1) < meanish
      upperCut = i+1;
      break;
    end
  end
  
  if figuresOn
    %normSummedScanlines = (summedVertScanlines/max(summedVertScanlines))*plateImgWidth;
    %figure(21), imshow(contrastImg), title('contrast image');
    figure(21), plot(summedVertScanlines);
    hold on;
    plot(1:plateImgHeight,meanish,'b-');
    plot(lowerCut,meanish-100,'rx');
    plot(upperCut,meanish-100,'rx');
    hold off;
  end

  % find top- and bottom cuts
  %scanlineSums = sum(bwImg,2);
  %scanlineSums = sum(contrastImg,2);
  %bottomSums = scanlineSums(1:plateMiddle,:);
  %topSums = scanlineSums(plateMiddle:plateImgHeight,:);
  %[maxBottom,lowerCut] = max(bottomSums)
  %[maxTop,upperCut] = max(topSums)
  %upperCut = upperCut + plateMiddle
  
    
  %%%%%%%%%%%%%%%%%%%%%%%%%
  % CUT AND RETURN CHARS  %
  %%%%%%%%%%%%%%%%%%%%%%%%%
  
  foundChars = 7;
  
  % for removing white spaces
  charHeight = upperCut - lowerCut + 1;

  % cut out chars, roughly
  plotPos = 13;
  for charNo = 1:7
    
    % find x-coordinates using peaks
    [xMin, minIndex] = min(maxPeaks);
    maxPeaks(minIndex) = inf;
    [xMax, maxIndex] = min(maxPeaks);
    
    % adjust coordinates if they point outside the image
    if xMin < 1
      xMin = 1;
    end
    if xMax > plateImgWidth
      xMax = plateImgWidth;
    end
    
    % remove white spaces on both sides of char
    %sum(bwImg(lowerCut:upperCut,xMin))
    while sum(bwImg(lowerCut:upperCut,xMin)) == charHeight && xMin < xMax
      xMin = xMin + 1;
    end
    while sum(bwImg(lowerCut:upperCut,xMax)) == charHeight && xMin < xMax
      xMax = xMax - 1;
    end
    
    % TO-DO: Remember to return logical image (im2bw at last like in cc)
    % add image of a char to the struct chars (indexed by 'char1',
    % 'char2' etc.) display char afterwards
    charName = strcat('char',int2str(charNo));
    %chars.(charName) = img(yMin:yMax,xMin:xMax,:);
    chars.(charName) = plateImg(lowerCut:upperCut,xMin:xMax,:);
    %chars(:,:,:,charNo) = plateImg(lowerCut:upperCut,xMin:xMax,:);
    charCoords(charNo,1) = xMin + plateCoords(1);
    charCoords(charNo,2) = xMax + plateCoords(1);
    charCoords(charNo,3) = lowerCut + plateCoords(3);
    charCoords(charNo,4) = upperCut + plateCoords(3);
    
    % display char
    if figuresOn
      figure(22), subplot(7,3,plotPos), imshow(chars.(charName)), title(charName);
      %figure(22), subplot(7,3,plotPos), imshow(chars(:,:,charNo)), title((charNo));
    end
    
    % save char
    %imwrite(chars.(charName),'bla.jpg','jpg')
    
    plotPos = plotPos + 1;
    
  end  
  
end