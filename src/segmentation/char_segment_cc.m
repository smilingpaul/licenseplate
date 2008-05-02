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
  
  % get and display plate image
  %plateImg = img(plateCoords(3):plateCoords(4),plateCoords(1):plateCoords(2),:);
  %if figuresOn
  %  figure(2), subplot(9,4,1:4), imshow(plateImg), title('plateImg');
  %end  
  
  % create grayscale image
  grayImg = rgb2gray(plateImg);
  
  %grayImg = [ 2 3 4 10 110 2 9 1 4; 3 1 100 34 99 87 2 1 255; 233 12 1 80 70 40 2 9 12; 233 12 1 80 70 40 2 9 12; 100 10 200 180 110 20 1 2 22]
  
  if figuresOn
    figure(2), subplot(9,4,1:4), imshow(grayImg), title('gray plateImg');
  end
  
  %figure(2), subplot(2,1,1), imshow(grayImg), title('gray plateImg');
  
  % dilate
  %se = strel('square',2);
  %se = strel('disk',2);
  %dilatedGrayImg = imdilate(grayImg,se);

  % calculate width and height of images
  %imgHeight = size(img,1);
  %imgWidth = size(img,2);
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
  
  %figure(2), subplot(8,4,13:16), imshow(imgContrastEnh), title('original +
  %top-hat - bottom-hat');
  
  %%%%% BRIGHTNESS / CONTRAST %%%%%%%%
  %meanVal = mean(mean(grayImg))
  
  %brightImg = uint8((double(grayImg)/180)*256);
  %brightImg = uint8((double(grayImg)/mean(mean(grayImg)))*256);
 
  %contrastImg = ContrastStretch(medianFilteredImg,0);
  contrastImg = ContrastStretch(grayImg,0);
  %contrastImg = ContrastStretch(brightImg,0);
  %contrastImg = ContrastStretch(dilatedGrayImg,0);
  
  
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
  
  
  %%%%%%%%%%%% TO-DO: determine level. In LicensplateSydney.pdf level is
  %%%%%%%%%%%% based on the average gray scale value of the 100 pixels with
  %%%%%%%%%%%% the largest gradient. Do we need that?
  %thresh = graythresh(contrastImg)
  bwPlate = im2bw(contrastImg,graythresh(contrastImg));
  %bwPlate = im2bw(dilatedContrastImg,graythresh(dilatedContrastImg));
  %bwPlate = im2bw(contrastImg,0.7);
  %bwPlate = im2bw(brightImg,graythresh(brightImg));
  if figuresOn
    %figure(2), subplot(8,4,5:8), imshow(dilatedGrayImg), title('dilated gray image');
    %figure(2), subplot(9,4,5:8), imshow(medianFilteredImg), title('median');
    %figure(2), subplot(8,4,5:8), imshow(grayImg), title('gray image');
    figure(2), subplot(9,4,9:12), imshow(contrastImg), title('contrast image');
    %figure(2), subplot(9,4,5:8), imshow(brightImg), title('brightness image');
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
  %isCandidate = zeros(noOfComp,1);
  %candidateGroup 
  
  
  candidates = zeros(noOfComp,4);
  noOfCandidates = 0;
  
  %charHeightSum = 0;
  %charWidthSum = 0;
  %maxCharHeight = 0;
  %maxCharWidth = 0;
  
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
      %isCandidate(i) = true;
      
      
      candidates(i,1) = 1;
      noOfCandidates = noOfCandidates + 1;
      candidates(i,2) = compHeight;
      
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
  
  heightMaxDif = 5;
  
  if noOfCandidates > 7
    
    % for each candidate: calculate how many other candidates that have
    % similar height
    for i = 1:noOfComp
      
      for j = 1:noOfComp
        
        
        % pos. 1, holds if the component is a candidate
        if candidates(i,1) && candidates(j,1) && i ~= j
          
          % find all pixels in components
          [y_i,x_i] = find(conComp == i);
          [y_j,x_j] = find(conComp == j);
          yMiddleI = (max(y_i)+min(y_i))/2;
          yMiddleJ = (max(y_j)+min(y_j))/2;
          
          % register no. af components with same height
          if abs(candidates(i,2) - candidates(j,2)) <= heightMaxDif
            candidates(i,3) = candidates(i,3) + 1;
          end
          % register no. of components at same height
          if abs(yMiddleI - yMiddleJ) <= heightMaxDif
            candidates(i,4) = candidates(i,4) + 1;
          end
        end
      end
      
      % remove if not 6 others HAVE similar height or AT same height
      if candidates(i,1) && (candidates(i,3) < 6 || candidates(i,4) < 6)
        candidates(i,:) = 0;
        noOfCandidates = noOfCandidates - 1;
        
        % set color of pixels in component to black
        compSize = length(find(conComp == i));
        [y,x] = find(conComp == i);
        for j = 1:compSize
          conComp(y(j), x(j)) = 0;
        end
        
      end
      
    end
    
  end
  
  foundChars = noOfCandidates
  
  % show connected components that haven't been removed
  if figuresOn
    figure(2), subplot(9,4,25:28), imshow(conComp), title('conComp cleaned');
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % DISPLAY AND RETURN CHARS %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  if foundChars ~= 7
    return;
  else
    % char number
    charNo = 1;
  
    % for displaying the chars
    plotPos = 29;
    
    % cut out chars
    for i = 1:noOfComp
      
      % if the component is a candidate: cut it out
      if candidates(i,1)
        [y,x] = find(conComp == i);
        
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
        %chars.(charName) = img(yMin:yMax,xMin:xMax,:);
        %chars.(charName) = plateImg(yMin:yMax,xMin:xMax,:);
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
        charNo = charNo + 1;
        %imgNo = imgNo + 1;
              
      end
      
    end
  end
  
end