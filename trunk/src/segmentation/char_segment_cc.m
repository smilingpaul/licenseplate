% Function to pick out the chars of a licenseplate in an image using
% connected components. Plate must be located and rotated so it is
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
function [chars, charCoords, foundChars] = char_segment_cc (plateImg, figuresOn) 

  chars.field1 = zeros(1,1);
  chars.field2 = zeros(1,1);
  chars.field3 = zeros(1,1);
  chars.field4 = zeros(1,1);
  chars.field5 = zeros(1,1);
  chars.field6 = zeros(1,1);
  chars.field7 = zeros(1,1);
  charCoords = zeros(7,4);
  %foundChars = 0;
  
  % display image
  if figuresOn
    figure(2), subplot(8,4,1:4), imshow(plateImg), title('plateImg');
  end
  
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
  imHeight = size(plateImg,1);
  imWidth = size(plateImg,2);
  
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
  
  %%%%% Experiments: BRIGHTNESS %%%%%%%%
  grayImg = uint8((double(grayImg)/180)*256);
  imgContrastEnh = im2bw(grayImg,graythresh(grayImg));
  if figuresOn
    figure(2), subplot(8,4,5:8), imshow(grayImg), title('brigtnessEnh image');
    figure(2), subplot(8,4,9:12), imshow(imgContrastEnh), title('brigtnessEnh bw image');
  end
  
  
  % created connected components from bwImg
  %[conComp,noOfComp] = bwlabel(~bwImg);
  [conComp,noOfComp] = bwlabel(~imgContrastEnh);
  if figuresOn
    figure(2), subplot(8,4,17:20), imshow(conComp), title('~conComp');
  end
  
  % return if not enough chars has been found
  foundChars = noOfComp;
  if foundChars < 7
    return;
  end
  
  %%%%%%%%%%%% remove components that are too big or too %%%%%%%%%%%%
  %%%%%%%%%%%% small and components that are too thin    %%%%%%%%%%%%
  %%%%%%%%%%%% TO-DO: tweak variables!!!!!!!!!!!!!       %%%%%%%%%%%%
  
  maxCompSize = (imHeight*imWidth)/7;
  %minCompSize = (imHeight*imWidth)/150;
  minCompSize = 5;
  maxCompWidth = imWidth/7;
  %minCompWidth = 3;
  minCompHeight = 5;
  
  %compRemoved = zeros(noOfComp,1);
  
  % create list of char candidates, pos. 1 store wheter the component is a
  % candidate, pos. 2 stores the height of the component in pixels, pos. 3
  % stores the no. of components with a similar height.
  isCandidate = zeros(noOfComp,3);
  candidates = 0;
  
  charHeightSum = 0;
  charWidthSum = 0;
  maxCharHeight = 0;
  maxCharWidth = 0;
  
  % find candidates
  for i = 1:noOfComp
    
    % calculate length of component and all pixels in component
    compSize = length(find(conComp == i));
    [y,x] = find(conComp == i);
    compWidth = max(x) - min(x);
    compHeight = max(y) - min(y);
    
    % take only obvious components as candidates
    if compSize <= maxCompSize && compWidth <= maxCompWidth && ...
        compWidth < compHeight && compSize >= minCompSize && ...
        compHeight >= minCompHeight
      
      isCandidate(i,1) = 1;
      candidates = candidates + 1;
      isCandidate(i,2) = compHeight;
      %isCandidate(i,3) = 1;
      %isCandidate(i,3) = max(x);
      %isCandidate(i,4) = min(y);
      %isCandidate(i,5) = max(y);
      
      charHeightSum = charHeightSum + compHeight;
      charWidthSum = charWidthSum + compWidth;
      
      if compHeight > maxCharHeight
        maxCharHeight = compHeight;
      elseif compWidth > maxCharWidth
        maxCharWidth = compWidth;
      end
      
    end
    
  end
  
  % FOR TEST: remove non-candidates from connected component image
  %for i = 1:noOfComp
  %
  %    if ~isCandidate(i,1)
  %
  %      % register that component has been removed
  %      %compRemoved(i) = true;
  %
  %      % set color of pixels in component to black
  %      compSize = length(find(conComp == i));
  %      [y,x] = find(conComp == i);
  %      for j = 1:compSize
  %        conComp(y(j), x(j)) = 0;
  %      end
  % 
  %     end
  %
  %end
  
  %figure(2), subplot(8,4,21:24), imshow(conComp), title('conComp semi-cleaned');
  
  % remove more candidates by looking at ratios if no. of candidates is > 7
  %ratioDifs = zeros(noOfComp,1);
  %candidateHeights = zeros(candidates,1);
  
  heightMaxDif = 5;
  c = 1;
  
  if candidates > 7
    %charAvgHeight = charHeightSum / candidates;
    %charAvgWidth = charWidthSum / candidates;
    %charAvgRatio = charAvgHeight / charAvgWidth;
    
    %for i = 1:noOfComp
      %compHeight = isCandidate(i,3) - isCandidate(i,2)
      %compWidth = isCandidate(i,5) - isCandidate(i,4)
      %compRatio = compWidth / compHeight;
      %if isCandidate(i,1)
        
        %candidateHeights(c) = isCandidate(i,2);
        %c = c + 1;
        %i
        %compRatio = (isCandidate(i,5) - isCandidate(i,4)) / (isCandidate(i,3) - isCandidate(i,2))
        %ratioDifs(i) = compRatio;
        %compRatioDif = charAvgRatio - compRatio
        
        %if (isCandidate(i,5) - isCandidate(i,4) / isCandidate(i,3) - isCandidate(i,2)) < charAvgHeight
        %  isCandidate(i,:) = 0;
        %  candidates = candidates - 1;
        %end
        
      %end
      
      
      
    %end
    
    for i = 1:noOfComp
      for j = 1:noOfComp
        
        % find how many other candidates that have similar height
        if isCandidate(i,1)
          if i ~= j && isCandidate(j,1) && abs(isCandidate(i,2) - isCandidate(j,2)) <= heightMaxDif
            isCandidate(i,3) = isCandidate(i,3) + 1;
          end
        end
        
      end
      
      % remove if not 6 others have similar height
      if isCandidate(i,1) && isCandidate(i,3) ~= 6
        isCandidate(i,:) = 0;
        candidates = candidates - 1;
      end
      
    end
    
    
    
    % remove candidate with worst ratio score
    %[worstRatio, index] = max(ratioDifs)
    %isCandidate(index,:) = 0;
    %ratioDifs(index) = 0;
    %candidates = candidates - 1;
    
  end
  
  foundChars = candidates
  
  % for displaying: remove non-candidates from connected component image
  for i = 1:noOfComp
  
      if ~isCandidate(i,1)
  
        % register that component has been removed
        %compRemoved(i) = true;
  
        % set color of pixels in component to black
        compSize = length(find(conComp == i));
        [y,x] = find(conComp == i);
        for j = 1:compSize
          conComp(y(j), x(j)) = 0;
        end
  
      end
  
  end
  
  
  % show connected components that haven't been removed
  if figuresOn
    figure(2), subplot(8,4,21:24), imshow(conComp), title('conComp cleaned');
  end
  
  if foundChars ~= 7
    return;
  else
    
    fieldNo = 1;
  
    %for displaying the chars
    plotPos = 25;
    
    % cut out chars
    for i = 1:noOfComp
      
      % if the component hasn't been removed it's likely a char: cut it out
      if isCandidate(i,1)
        [y,x] = find(conComp == i);
        
        xMin = min(x)-2; xMax = max(x)+2;
        yMin = min(y)-2; yMax = max(y)+2;
        
        % adjust coordinates if they point outside the image
        if xMin < 1
          xMin = 1;
        end
        if xMax > imWidth
          xMax = imWidth;
        end
        if yMin < 1
          yMin = 1;
        end
        if yMax > imHeight
          yMax = imHeight;
        end
        
        % add image of a char to the struct chars (indexed by 'field1',
        % 'field2' etc.) display char afterwards
        fieldName = strcat('field',int2str(fieldNo));
        chars.(fieldName) = plateImg(yMin:yMax,xMin:xMax,:);
        charCoords(fieldNo,1) = xMin;
        charCoords(fieldNo,2) = xMax;
        charCoords(fieldNo,3) = yMin;
        charCoords(fieldNo,4) = yMax;
        if figuresOn
          figure(2), subplot(8,4,plotPos), imshow(chars.(fieldName)), title(fieldName);
        end
        
        % iterate
        plotPos = plotPos + 1;
        fieldNo = fieldNo + 1;
              
      end
      
    end
  end
  
end