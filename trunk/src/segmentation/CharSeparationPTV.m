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
function [chars, charCoords, foundChars] = CharSeparationPTV (plateImg, plateCoords, figuresOn) 

  % set variables
  threshFactor = 0.8;
  blockSize = 17;

  %%%%%%%%%%%%%%%%%%
  % PRE-PROCESSING %
  %%%%%%%%%%%%%%%%%%

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
  grayImg = rgb2gray(plateImg);
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % SHRINK PLATEIMG TO LARGEST COMPONENT %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  grayImg2bw = im2bw(grayImg,graythresh(grayImg)*(threshFactor^2));
  [testing, testing2] = bwlabel(grayImg2bw);
  
  if figuresOn
    figure(22), subplot(7,4,1:4), imshow(plateImg), title('plateImg');
    figure(22), subplot(7,4,5:8), imshow(testing), title('testing');
  end
  
  % find largest component and its coordinates
  maxSize = 1;
  maxComp = 1;
  for i = 1:testing2
    compSize = length(find(testing == i));
    if compSize > maxSize
      maxComp = i;
      maxSize = compSize;
    end
  end
  [y,x] = find(testing == maxComp);
  
  % shrink
  grayImg = grayImg(min(y):max(y),min(x):max(x));
  
  %%%%%%%%%%%%
  % CONTRAST %
  %%%%%%%%%%%%

  % calculate width and height of images
  plateImgHeight = size(grayImg,1);
  plateImgWidth = size(grayImg,2);
  
  xShrink = min(x)-1;
  yShrink = min(y)-1;

  % calculate 'y-middle' of image
  plateMiddle = round(plateImgHeight / 2);
  

  function result = BlockContrast (block)
    
    contrastedBlock = ContrastStretch(block,0);
    
    result = contrastedBlock(ceil(blockSize/2),ceil(blockSize/2));
    
  end
  
  %if brigthenImg
  %  %brightImg = uint8((double(grayImg)/180)*256);
  %  brightImg = uint8((double(grayImg)/mean(mean(grayImg)))*256);
  %  %contrastImg = ContrastStretch(brightImg,0);
  %  %contrastImg = nlfilter(grayImg, [5 5],@bla);
  %  contrastImg = blkproc(grayImg, [5 5],@bla);
  %else
    %contrastImg = ContrastStretch(medianFilteredImg,0);
    %contrastImg = ContrastStretch(grayImg,0);
    contrastImg = nlfilter(grayImg, [blockSize blockSize],@BlockContrast);
    %contrastImg = blkproc(grayImg, [13 13],@bla);
    %contrastImg = ContrastStretch(dilatedGrayImg,0);
  %end
  
  %% MEDIAN FILTER
  %{
  medianFilteredImg = contrastImg;
  windowSize = 5;
   
  for i = ceil(windowSize/2):plateImgHeight - floor(windowSize/2)
    for j = ceil(windowSize/2):plateImgWidth - floor(windowSize/2);
      medianWindow = grayImg(i-floor(windowSize/2):i+floor(windowSize/2), ...
        j-floor(windowSize/2):j+floor(windowSize/2));
      medianFilteredImg(i,j) = median(median(medianWindow));
    end
  end
  
  %medianFilteredImg
  %figure(2), subplot(2,1,2), imshow(medianFiltered), title('median');
  %}
  
  %se = strel('line',4,90);
  %dilatedBW = imerode(contrastImg,se);
  
  %bwImg = im2bw(dilatedBW,graythresh(dilatedBW)*threshFactor);
  %bwImg = im2bw(contrastImg,0.2);
  %bwImg = im2bw(brightImg,graythresh(brightImg));
  %bwImg = im2bw(grayImg,graythresh(grayImg)*threshFactor);
  bwImg = im2bw(contrastImg,graythresh(contrastImg)*threshFactor);
  
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % GET SIGNATURES ACROSS SCANLINES %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  % used for smoothing plate signature
  smoothFactor = floor(plateImgWidth / 35);
  
  % buffer to look for peaks
  bufferSize = floor(plateImgWidth / 20);
  if mod(bufferSize,2) == 1
    bufferSize = bufferSize + 1;
  end
  
  % sum up lines
  summedScanlines = zeros(1,plateImgWidth);
  
  % sum up scanlines: entire image
  for i = 1:plateImgHeight
    %summedScanlines = summedScanlines + double(contrastImg(i,:));
    summedScanlines = summedScanlines + double(bwImg(i,:));
  end
  
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%
  % SMOOTHING OF SIGNATURE %
  %%%%%%%%%%%%%%%%%%%%%%%%%%
  
  meanSummedScanlines = zeros(size(summedScanlines));
  
  % smoothen with simple average function
  for i = 1:plateImgWidth
    
    % determine the first and last for calculating mean of current
    first = i-smoothFactor+1;
    last = i+smoothFactor;
    
    % correct first and last if one of them point outside plate image
    if first < 1
      dif = 1 - first;
      first = 1;
      last = last - dif;
    end
    if last > plateImgWidth
      dif = last - plateImgWidth;
      last = plateImgWidth;
      first = first + dif;
    end
    
    % calculate mean
    meanSummedScanlines(i) = mean(summedScanlines(first:last));
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
  
  % mark spots that are peaks
  for i = (bufferSize/2)+1:size(meanSummedScanlines,2)-(bufferSize/2)
    
    buffer = meanSummedScanlines(i-(bufferSize/2):i+(bufferSize/2));
    
    % determine if we were going up until now
    for n = 1:bufferSize/2
      if buffer(n) <= buffer(bufferSize/2+1)
        goingUp = true;
      else
        goingUp = false;
        break;
      end
    end
    
    % determine if we are going down after current position
    if goingUp
      for n = bufferSize/2+2:bufferSize
        if buffer(bufferSize/2+1) >= buffer(n)
          peakReached = true;
        else
          peakReached = false;
          break;
        end
      end
    else
      peakReached = false;
    end
    
    % if there's a peak: register it
    bufferIndexes = i-(bufferSize/2):i+(bufferSize/2);
    if peakReached && (peakNo == 1 || isempty(find(bufferIndexes == allPeaks(peakNo-1,1),1)))
      allPeaks(peakNo,1) = i;
      allPeaks(peakNo,2) = meanSummedScanlines(i);
      peakNo = peakNo + 1;
    end
    
  end
  
  % return if not enough peaks has been found
  if size(allPeaks,1) < 8
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
  
  
  % display grayImg, brightImg and contrastImg
  % plot meanSummedScanlines and found peaks
  if figuresOn
    normSummedScanlines = (meanSummedScanlines/max(meanSummedScanlines))*plateImgHeight;
    %figure(22), subplot(7,4,9:12), imshow(dilatedBW), title('dilatedBW');
    %figure(22), subplot(7,4,13:16), imshow(brightImg), title('brightImg');
    figure(22), subplot(7,4,9:12), imshow(contrastImg), title('contrastImg');
    figure(22), subplot(7,4,13:20), imshow(~bwImg), title('bwImg');
    %figure(65), imshow(contrastImg), title('contrastImg');
    hold on;
    plot(1:plateImgWidth, normSummedScanlines, 'y');
    %for j = 1:size(allPeaks)
    %  plot(allPeaks(j), plateMiddle, 'gx');
    %end
    %for i = 1:8
    %  line(maxPeaks(i), 1:plateImgHeight);
    %  %plot(maxPeaks(i), 1:plateImgHeight, 'b-');
    %end
    hold off;
  end  
  
    
  %%%%%%%%%%%%%%%%%%%%%%%%%
  % CUT AND RETURN CHARS  %
  %%%%%%%%%%%%%%%%%%%%%%%%%
  
  lowerCut = 1;
  upperCut = plateImgHeight;
  
  foundChars = 7;

  % cut out chars, roughly
  plotPos = 21;
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
    
    grayCharImg = grayImg(1:plateImgHeight,xMin:xMax);
    charImg = ContrastStretch(grayCharImg,0);
    charImg = ~im2bw(charImg,graythresh(charImg)*(threshFactor^2));
    
    % find top- and bottom cuts
    bottomSums = sum(charImg(1:floor(size(charImg,1)/2),:),2);
    topSums = sum(charImg(floor(size(charImg,1)/2)+1:plateImgHeight,:),2);
    [minBottom,bottomCut] = min(bottomSums);
    [minTop,topCut] = min(topSums);
    topCut = topCut + floor(size(charImg,1)/2);
    
    charImg = charImg(bottomCut:topCut,:);
    
    % remove white spaces on both sides of char
    [y, x] = find(charImg == 1);
    charImg = charImg(min(y):max(y),min(x):max(x));
    
    % if image contained only white space (no char), image will be empty.
    % reset outputs and return
    if isempty(charImg)
      chars.field1 = zeros(1,1);
      chars.field2 = zeros(1,1);
      chars.field3 = zeros(1,1);
      chars.field4 = zeros(1,1);
      chars.field5 = zeros(1,1);
      chars.field6 = zeros(1,1);
      chars.field7 = zeros(1,1);
      charCoords = zeros(7,4);
      foundChars = 0;
      return;
    end
    

    charName = strcat('char',int2str(charNo));
    chars.(charName) = charImg;
    charCoords(charNo,1) = xMin + plateCoords(1) + xShrink;
    charCoords(charNo,2) = xMax + plateCoords(1) + xShrink;
    charCoords(charNo,3) = lowerCut + plateCoords(3) + yShrink;
    charCoords(charNo,4) = upperCut + plateCoords(3) + yShrink;
    
    % display char
    if figuresOn
      figure(22), subplot(7,4,plotPos), imshow(chars.(charName)), title(charName);
      %figure(22), subplot(7,3,plotPos), imshow(chars(:,:,charNo)), title((charNo));
      imwrite(chars.(charName),['/Users/epb/Documents/datalogi/3aar/bachelor/licenseplate/docs/rapport/system/illu/' charName '_ptv.png'],'png','BitDepth',1)
    end
    
    plotPos = plotPos + 1;
    
  end  
  
end