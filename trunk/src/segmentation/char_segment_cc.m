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

  brigthenImg = false;
  
  % down-scale image
  %plateImg = imresize(plateImg,0.5);

  %%%%%%%%%%%%%%%%%%
  % PRE-PROCCESING %
  %%%%%%%%%%%%%%%%%%
  
  % char height and - width
  %defaultCharHeight = 8;
  %defaultCharWidth = 5;
  %chars = zeros(defaultCharHeight,defaultCharWidth,7);
  
  % create outputs
  chars.char1 = zeros(1,1);
  chars.char2 = zeros(1,1);
  chars.char3 = zeros(1,1);
  chars.char4 = zeros(1,1);
  chars.char5 = zeros(1,1);
  chars.char6 = zeros(1,1);
  chars.char7 = zeros(1,1);
  charCoords = zeros(7,4); % contains 4 coordinates for each of the 7 chars
  %foundChars = 0;
  
  % create grayscale image
  grayImg = rgb2gray(plateImg);
  
  %grayImg = [ 2 3 4 10 110 2 9 1 4; 3 1 100 34 99 87 2 1 255; 233 12 1 80 70 40 2 9 12; 233 12 1 80 70 40 2 9 12; 100 10 200 180 110 20 1 2 22]
  
  if figuresOn
    figure(2), subplot(9,4,1:4), imshow(grayImg), title('gray plateImg');
  end
  
  % dilate
  %se = strel('square',2);
  %se = strel('disk',2);
  %dilatedGrayImg = imdilate(grayImg,se);

  % calculate width and height of images
  plateImgHeight = size(grayImg,1);
  plateImgWidth = size(grayImg,2);
  
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
  
  %%%%% Experiments: TOP AND BOTTOM HAT %%%%%%%%
  %se = strel('disk', 15);
  %imgTophat = imtophat(grayImg, se);
  %imgBothat = imbothat(grayImg, se);
  %figure(2), subplot(9,4,5:8), imshow(imgTophat, []), title('top-hat image');
  %figure(2), subplot(9,4,9:12), imshow(imgBothat, []), title('bottom-hat image');
  
  %imgContrastEnh = imsubtract(imadd(imgTophat, grayImg), imgBothat);
  
  %%%%% BRIGHTNESS / CONTRAST %%%%%%%%
  
  function trala = bla (blabla)
    
    trala = ContrastStretch(blabla,0);
    
    %result = trala(3,3);
    
  end
  
  %topmeanVal = mean(mean(grayImg(1:plateImgHeight/2,:)))
  %overallthresh = graythresh(grayImg)
  
  if brigthenImg
    %brightImg = uint8((double(grayImg)/180)*256);
    brightImg = uint8((double(grayImg)/mean(mean(grayImg)))*256);
    %contrastImg = ContrastStretch(brightImg,0);
    %contrastImg = nlfilter(grayImg, [5 5],@bla);
    contrastImg = blkproc(grayImg, [5 5],@bla);
  else
    %contrastImg = ContrastStretch(medianFilteredImg,0);
    %contrastImg = ContrastStretch(grayImg,0);
    %contrastImg = nlfilter(grayImg, [5 5],@bla);
    contrastImg = blkproc(grayImg, [13 13],@bla);
    %contrastImg = ContrastStretch(dilatedGrayImg,0);
  end
  
  % dilate
  %se = strel('square',2);
  %se = strel('disk',2);
  %dilatedContrastImg = imdilate(contrastImg,se);

  % set horizontal lines with high whiteness to "all white"
  %summedLines = sum(contrastImg,2);
  %avgWhiteness = mean(summedLines)
  %maxWhiteness = max(summedLines)
  %
  %for i = 1:size(summedLines,1)
  %  %if summedLines(i) > avgWhiteness+10000
  %  if summedLines(i) >= maxWhiteness-1000
  %    contrastImg(i,:) = 255;
  %  end
  %end
  
  thresh = graythresh(contrastImg)*0.4;
  %thresh = graythresh(contrastImg);
  bwPlate = im2bw(contrastImg,thresh);
  
  %topbwplate = im2bw(contrastImg(1:floor(plateImgHeight/2),:),graythresh(contrastImg(1:floor(plateImgHeight/2),:)));
  %btbwplate = im2bw(contrastImg(floor(plateImgHeight/2)+1:plateImgHeight,:),graythresh(contrastImg(floor(plateImgHeight/2)+1:plateImgHeight,:)));
  %bwPlate(1:floor(plateImgHeight/2),:) = topbwplate;
  %bwPlate(floor(plateImgHeight/2)+1:plateImgHeight,:) = btbwplate;
  
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
  
  % dilate bw image
  %se = strel('square',2);
  %se = strel('disk',2);
  %dilatedBwPlate = imdilate(bwPlate,se);
  
  %if figuresOn
  %  figure(2), subplot(9,4,17:20), imshow(dilatedBwPlate), title('dilated bw image');
  %end
  
  % created connected components from bwImg
  %[conComp,noOfComp] = bwlabel(~dilatedBwPlate);
  [conComp,noOfComp] = bwlabel(~bwPlate);
  if figuresOn
    figure(2), subplot(9,4,17:20), imshow(conComp), title('~conComp');
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
  
  %compRemoved = zeros(noOfComp,1);
  
  % create list of char candidates, pos. 1 store wheter the component is a
  % candidate, pos. 2 stores the height of the component in pixels, pos. 3
  % stores the no. of components with a similar height. pos. 4 stores no.
  % of components AT same height.
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
    if compSize <= maxCompSize && compWidth <= maxCompWidth && ...
        compSize >= minCompSize && compWidth >= minCompWidth && ...
        compHeight >= minCompHeight
      
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

      % check horizontal distances between components in group
      if groupIndex-1 == 7

        % sort by increasing "middle" in charGroup
        for x = 1:7
          [minMiddle, minIndex] = min(candidateGroup(:,2));
          compNo = candidateGroup(minIndex,1);
          charGroup(x,1) = compNo;
          charGroup(x,2) = minMiddle;
          candidateGroup(minIndex,2) = nan;
        end          

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
      % components in group       
      for r = 1:groupIndex-1
        compNo = candidateGroup(r,1);
        isCandidate(compNo) = false;
        noOfCandidates = noOfCandidates - 1;

        % set color of pixels in component to black
        [y,x] = find(conComp == compNo);
        compSize = length(find(conComp == compNo));
        for c = 1:compSize
          conComp(y(c), x(c)) = 0;
        end
        
        % reset charGroup
        charGroup(:,:) = 0;
        
      end
     
    end % isCandidate(i)
      
  end % i
  
  % TO-DO: remove components that are not in charGroup
  
  % up-scale image again
  %conComp = imresize(conComp,2);
  
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
      chars.(charName) = conComp(yMin:yMax,xMin:xMax);
      charCoords(charNo,1) = xMin + plateCoords(1);
      charCoords(charNo,2) = xMax + plateCoords(1);
      charCoords(charNo,3) = yMin + plateCoords(3);
      charCoords(charNo,4) = yMax + plateCoords(3);
      if figuresOn
        figure(2), subplot(9,4,plotPos), imshow(chars.(charName)), title(charName);
      end
        
      % increment variables
      plotPos = plotPos + 1;
      
    end
  end
  
end