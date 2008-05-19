% Function to pick out the chars of a licenseplate in an image using
% connected components. Plate must be located and rotated so it is
% placed horizontally in the image. The function returns the cut-out chars
% and a count on how many chars that have been found.
% 
% Input parameters:
% - img: image of a car with a licenseplate where the img has been
%   rotated so the plate is horizontal in the image.
% - plateCoords: the coordinates of the plate
% - figuresOn: true/false whether figures should be printed.
% 
% Output parameters:
% - chars: a struct containing the images of the seven chars found. 
% - charCoords: the coordinates of the chars
% - foundChars: the no. of found char candidates
function [chars, charCoords, foundChars] = char_segment_cc (plateImg, plateCoords, figuresOn) 

  % whether the image should be brigthened
  brigthenImg = false;
  
  % from 0 to 1. if high: less white in bwImg
  threshFactor = 0.8;
  
  % from 0 to 1. if low: the image will be downscaled a lot
  downScaleFactor = 1;
  
  % blocksize for contrast function
  blockSize = 17;

  %%%%%%%%%%%%%%%%%%
  % PRE-PROCCESING %
  %%%%%%%%%%%%%%%%%%
  
  % create outputs
  chars.char1 = zeros(1,1);
  chars.char2 = zeros(1,1);
  chars.char3 = zeros(1,1);
  chars.char4 = zeros(1,1);
  chars.char5 = zeros(1,1);
  chars.char6 = zeros(1,1);
  chars.char7 = zeros(1,1);
  charCoords = zeros(7,4); % contains 4 coordinates for each of the 7 chars
  
  % down-scale image
  plateImg = imresize(plateImg,downScaleFactor);
  
  % create grayscale image
  grayImg = rgb2gray(plateImg);
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % SHRINK PLATEIMG TO LARGEST COMPONENT %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  grayImg2bw = im2bw(grayImg,graythresh(grayImg)*(threshFactor^2));
  [testing, testing2] = bwlabel(grayImg2bw);
  
  if figuresOn
    figure(2), subplot(9,4,1:4), imshow(plateImg), title('plateImg');
    figure(2), subplot(9,4,5:8), imshow(testing), title('testing');
  end
  
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
  
  
  plateImg = plateImg(min(y):max(y),min(x):max(x),:);
  
  % create grayscale image
  grayImg = rgb2gray(plateImg);

  % calculate width and height of images
  plateImgHeight = size(grayImg,1);
  plateImgWidth = size(grayImg,2);
  
  xShrink = min(x)-1;
  yShrink = min(y)-1;
  %xShrink = 0;
  %yShrink = 0;
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % ENHANCE CONTRAST AND CREATE CONNECTED COMPONENTS %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  %%%%%%%%%%%%% TO-DO: Filtering or watersheding? %%%%%%%%%%%%%%%%
  
  %% MEDIAN FILTER
  %medianFilteredImg = grayImg;
  %windowSize = 5;
  % 
  %for i = ceil(windowSize/2):plateImgHeight - floor(windowSize/2)
  %  for j = ceil(windowSize/2):plateImgWidth - floor(windowSize/2);
  %    medianWindow = grayImg(i-floor(windowSize/2):i+floor(windowSize/2), ...
  %      j-floor(windowSize/2):j+floor(windowSize/2));
  %    medianFilteredImg(i,j) = median(median(medianWindow));
  %  end
  %end
  
  %medianFilteredImg
  %figure(2), subplot(2,1,2), imshow(medianFiltered), title('median');
  
  %imgContrastEnh = imsubtract(imadd(imgTophat, grayImg), imgBothat);
  
  %%%%% BRIGHTNESS / CONTRAST %%%%%%%%
  
  % blocksize for contrast function
  %if plateImgWidth > 200
  %  blockSize = 11;
  %else
  %  blockSize = 17;
  %end
  
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
  
  bwPlate = im2bw(contrastImg,graythresh(contrastImg)*threshFactor);  
  %bwPlate = im2bw(dilatedContrastImg,graythresh(dilatedContrastImg));
  %bwPlate = im2bw(contrastImg,0.7);
  %bwPlate = im2bw(brightImg,graythresh(brightImg));
  
  if figuresOn
    %figure(2), subplot(8,4,5:8), imshow(dilatedGrayImg), title('dilated gray image');
    %figure(2), subplot(9,4,5:8), imshow(medianFilteredImg), title('median');
    %figure(2), subplot(8,4,5:8), imshow(grayImg), title('gray image');
    figure(2), subplot(9,4,9:12), imshow(contrastImg), title('contrast image');
    if brigthenImg
      figure(2), subplot(9,4,5:8), imshow(brightImg), title('brightness image');
    end
    figure(2), subplot(9,4,13:16), imshow(bwPlate), title('bw image');
  end
  
  % pad 0's on the edge of the image: 1 pixel wide
  plateImgHeight = plateImgHeight + 2;
  plateImgWidth = plateImgWidth + 2;  
  negBwPlate = zeros(plateImgHeight,plateImgWidth);
  negBwPlate(2:plateImgHeight-1,2:plateImgWidth-1) = ~bwPlate;
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%
  % REMOVE THIN COMPONENTS %
  %%%%%%%%%%%%%%%%%%%%%%%%%%
  
  function result = RemoveThinComps (area)

    result = area(1,2);
    if area(1,2) ~= 0
      if (area(1,1) == 0 && area(1,3) == 0)
        result = 0;
      end
    end

  end
  
  % remove thin components in 1/3 of top plus 1/10 of the sides
  negBwPlate(1:floor(plateImgHeight/3),:) = ...
    nlfilter(negBwPlate(1:floor(plateImgHeight/3),:), [1 3],@RemoveThinComps);
  negBwPlate(:,1:floor(plateImgWidth/10)) = ...
    nlfilter(negBwPlate(:,1:floor(plateImgWidth/10)), [1 3],@RemoveThinComps);
  negBwPlate(:,floor(plateImgWidth*9/10):plateImgWidth) = ...
    nlfilter(negBwPlate(:,floor(plateImgWidth*9/10):plateImgWidth), [1 3],@RemoveThinComps);
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % REMOVE HORIZONTAL LINES WITH ONLY A FEW/MANY WHITES %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  for i = 1:plateImgHeight
    if sum(negBwPlate(i,:)) < plateImgWidth/10 || ...
        sum(negBwPlate(i,:)) > plateImgWidth/1.5
      negBwPlate(i,:) = 0;
    end
  end
  
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % CREATE CONNECTED COMPONENTS AND DISPLAY %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  % created connected components from bwImg
  [conComp,noOfComp] = bwlabel(negBwPlate(2:plateImgHeight-1,2:plateImgWidth-1));
  plateImgHeight = size(conComp,1);
  plateImgWidth = size(conComp,2);
  
  if figuresOn
    figure(2), subplot(9,4,17:20), imshow(conComp), title('conComp');
  end
  
  % return if not enough chars has been found
  foundChars = noOfComp;
  if foundChars < 7
    return;
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % REMOVE COMPONENTS THAT CAN'T BE CHAR CANDIDATES %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  % TO-DO: tweak variables
  
  maxCompSize = (plateImgHeight*plateImgWidth)/7;
  %minCompSize = (plateImgHeight*plateImgWidth)/150;
  minCompSize = 5;
  maxCompWidth = plateImgWidth/7;
  minCompWidth = 3;
  minCompHeight = 5;
  
  isCandidate = zeros(noOfComp,1);
  noOfCandidates = 0;
  
  % find candidates
  for i = 1:noOfComp
    
    % calculate length of component and find all pixels in component
    compSize = length(find(conComp == i));
    [y,x] = find(conComp == i);
    compWidth = max(x) - min(x);
    compHeight = max(y) - min(y);
    
    % take only obvious components as candidates. compWidth can be equal to
    % compHeight, e.g. if the char "8" has some dust etc. next to it.
    % component can not touch image edge
    if compSize <= maxCompSize && compWidth <= maxCompWidth && ...
        compSize >= minCompSize && compWidth >= minCompWidth && ...
        compHeight >= minCompHeight && ~(min(x) == 1) && ...
        ~(min(y) == 1) && ~(max(x) == plateImgWidth) && ...
        ~(max(y) == plateImgHeight)
      
      % register component as candidate
      isCandidate(i) = true;
      noOfCandidates = noOfCandidates + 1;
      
    else
      
      % remove from image if not a candidate
      for j = 1:compSize
        conComp(y(j), x(j)) = 0;
      end
      
    end
    
  end
  
  
  
  % show connected components that haven't been removed
  if figuresOn
    figure(2), subplot(9,4,21:24), imshow(conComp), title('conComp cleaned');
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % REMOVE CANDIDATES WHERE                            %
  % - NOT 6 OTHER CANDIDATES HAVE SAME HEIGHT          %
  % - NOT 6 OTHER CANDIDATES HAVE SAME AVERAGE Y-VALUE %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  % the maximum height difference
  heightMaxDif = 6;
  % this is the matrix to hold the component group that are the 7 chars
  charGroup = zeros(7,2);
    
  % for each candidate: calculate how many other candidates that have
  % similar height, are at same heigth, and for groups calculate the
  % distances between the components
  for i = 1:noOfComp
    
    if isCandidate(i)
      
      % find all facts about component i
      [iY,iX] = find(conComp == i);
      iHeight = max(iY) - min(iY);
      iVertMiddle = (min(iY) + max(iY))/2;
        
      % create list to hold components in same group. pos. 1 is
      % componentno. pos. 2 is component horizontal middle.
      candidateGroup = nan(noOfComp,2);
      groupIndex = 1;
    
      for j = 1:noOfComp

        if isCandidate(j)
          % find facts about component j
          [jY,jX] = find(conComp == j);
          jHeight = max(jY) - min(jY);
          jVertMiddle = (max(jY) + min(jY))/2;
          jHorzMiddle = (min(jX) + max(jX))/2;

          % register no. af components as a group with same height and at
          % same height
          if abs(iHeight - jHeight) <= heightMaxDif && ...
              abs(iVertMiddle - jVertMiddle) <= heightMaxDif
            candidateGroup(groupIndex,1) = j;
            candidateGroup(groupIndex,2) = jHorzMiddle;
            groupIndex = groupIndex + 1;
          end 
        end

      end % j
      
      % sort by increasing "middle" in charGroup
      for x = 1:groupIndex-1
        [minMiddle, minIndex] = min(candidateGroup(:,2));
        compNo = candidateGroup(minIndex,1);
        charGroup(x,1) = compNo;
        charGroup(x,2) = minMiddle;
        candidateGroup(minIndex,2) = nan;
      end
      
      % remove the two outermost components if there are 9 components in
      % group or the outermost component if there are 8 components.
      while size(charGroup,1) > 7
        if size(charGroup,1) >= 9
          charGroup = charGroup(2:size(charGroup,1)-1,:);
        else
          leftDist = charGroup(1,2);
          rightDist = plateImgWidth - charGroup(8,2);
          if rightDist < leftDist
            charGroup = charGroup(1:7,:);
          else
            charGroup = charGroup(2:8,:);
          end
        end
      end

      % check horizontal distances between components in group
      if size(charGroup,1) == 7
        
        % calculate distances
        dist1_2 = charGroup(2,2) - charGroup(1,2);
        dist2_3 = charGroup(3,2) - charGroup(2,2); % should be largest
        dist3_4 = charGroup(4,2) - charGroup(3,2);
        dist4_5 = charGroup(5,2) - charGroup(4,2); % should be largest
        dist5_6 = charGroup(6,2) - charGroup(5,2);
        dist6_7 = charGroup(7,2) - charGroup(6,2);

        % check distances
        if dist1_2 < dist2_3 && ...
            dist3_4 < dist2_3 && dist3_4 < dist4_5 && ...
            dist5_6 < dist2_3 && dist5_6 < dist4_5 && ...
            dist6_7 < dist2_3 && dist6_7 < dist4_5
          break;
        end

      end

      % if we didn't break, the distances are not right so remove
      % components in group from list of candidates      
      for r = 1:groupIndex-1
        compNo = candidateGroup(r,1);
        isCandidate(compNo) = false;
        noOfCandidates = noOfCandidates - 1;
        
        % reset charGroup
        charGroup(:,:) = 0;
      end
     
    end % isCandidate(i)
      
  end % i
  
  % remove components that are not in charGroup
  if isempty(find(charGroup == 0,1))
    for i = 1:noOfComp
      if isempty(find(charGroup == i,1))
        % set color of pixels in component to black
        [y,x] = find(conComp == i);
        compSize = length(find(conComp == i));
        for c = 1:compSize
          conComp(y(c), x(c)) = 0;
        end
      end
    end
  end
  
  % up-scale image again
  conComp = imresize(conComp,downScaleFactor);
  
  % show connected components that haven't been removed
  if figuresOn
    figure(2), subplot(9,4,25:28), imshow(conComp), title('conComp group cleaned');
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % DISPLAY AND RETURN CHARS %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  % if the charGroup has no content: return, else: cut chars
  if length(find(charGroup(:,1))) ~= 7
    foundChars = 0;
    return;
  else
    
    foundChars = 7;
  
    % for displaying the chars
    plotPos = 29;
    
    % cut out chars
    for charNo = 1:7
      
      % find component no.
      compNo = charGroup(charNo,1);
      [y,x] = find(conComp == compNo);
        
      xMin = min(x);
      xMax = max(x);
      yMin = min(y);
      yMax = max(y);
                
      % adjust coordinates if they point outside the image
      if xMin < 1
        xMin = 1;
      end
      if xMax > plateImgWidth
        xMax = plateImgWidth;
      end
      if yMin < 1
        yMin = 1;
      end
      if yMax > plateImgHeight
        yMax = plateImgHeight;
      end        
        
      % add image of a char to the struct chars (indexed by 'char1',
      % 'char2' etc.) display char afterwards
      charName = strcat('char',int2str(charNo));
      chars.(charName) = im2bw(conComp(yMin:yMax,xMin:xMax));
      charCoords(charNo,1) = xMin + plateCoords(1) + xShrink;
      charCoords(charNo,2) = xMax + plateCoords(1) + xShrink;
      charCoords(charNo,3) = yMin + plateCoords(3) + yShrink;
      charCoords(charNo,4) = yMax + plateCoords(3) + yShrink;
      if figuresOn
        figure(2), subplot(9,4,plotPos), imshow(chars.(charName)), title(charName);
      end
        
      % increment variables
      plotPos = plotPos + 1;
      
    end
  end
  
end