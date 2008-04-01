function [] = char_segment_scan (plateImg)

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %%%%%%%%%%%%%%%%% vertical scanlines: search for white lines %%%%%%%%%%%%
  %%%%%%%%%%%% find top and bottom from letters %%%%%%%%%%%%%%%

  % threshold for blackCount.
  % example of plate with minimum: JJ 21 111
  % example of plate with maximum: MN 48 888
  %blackThresMin = 7;
  %blackThresMax = 17;

  % find middle
  %middleLine = floor(size(bwImg,1)/2);

  % find blackCount
  %[blackCount, blackPos] = findBlackCount(bwImg,middleLine);
  
  % go up
  %topLine = middleLine - 1;
  %while blackCount > blackThresMin
  %  blackCount = findBlackCount(bwImg,topLine);
  %  topLine = topLine - 1;
  %end
  
  % go down
  %bottomLine = middleLine + 1;
  %while blackCount > blackThresMin
  %  blackCount = findBlackCount(bwImg,bottomLine);
  %  bottomLine = bottomLine + 1;
  %end
  
  % add a pixel to be sure that we're 'off' the chars
  %topLine = topLine - 1
  %bottomLine = bottomLine + 1
  
  %blackPos
  
  % there are 14 vertical cuts to be made, two for each of the seven chars
  %cuts = zeros(1,14);

  % whether we are going towards a char
  %toChar = true;

  %cutNo = 1;
  %charWidth = 0;
  %firstCharMet = false;
  %minCharWidth = 5;
  %s = 1;
  
  %allWhite = bottomLine - topLine + 1;
  
  %size(bwImg(topLine:bottomLine),1)

  % iterate through vertical scanlines
  %while cutNo < 15 && s < size(bwImg,1)
  %  
  %  % sums of the vertical scanlines
  %  lineSum = sum(bwImg(topLine:bottomLine,s))
  %  nextLineSum = sum(bwImg(topLine:bottomLine,s+1));
  %  
  %  % if the vertical line is all white
  %  if lineSum == allWhite
  %    firstCharMet = true;
  %    % position: in front of a char
  %    if toChar && nextLineSum < allWhite
  %      cuts(cutNo) = s;
  %      %s
  %      cutNo = cutNo + 1;
  %    % position: at the end of a char
  %    elseif nextLineSum == allWhite && charWidth > minCharWidth
  %      cuts(cutNo) = s;
  %      %s
  %      cutNo = cutNo + 1;
  %      charWidth = 0;
  %    end
  %  % position: in a char
  %  elseif firstCharMet
  %    charWidth = charWidth + 1;
  %  end
  %  % iterate
  %  s = s + 1;
  %end

  % add each image of a char to the struct chars (indexed by 'field1',
  % 'field2' etc.) display chars afterwards
  %plotPos = 3;
  %for c = 1:floor(cutNo/2)
  %  fieldName = strcat('field',int2str(c));
  %  chars.(fieldName) = plateImg(topLine:bottomLine,cuts(c):cuts(c+1),:);
  %  figure(1), subplot(3,3,plotPos), imshow(chars.(fieldName)), title(fieldName);
  %  plotPos = plotPos + 1;
  %end
  %
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %%%%%%%%%%%%%%%%% vertical scanlines: search for white lines %%%%%%%%%%%%

  % calculate no. of scanlines
  %h_scanlines = size(bwImg,1);
  
  % find the vertical middle of the image
  %v_middle = floor(h_scanlines/2);

  % calculate the sums of all horizontal scanlines
  %h_scanlines_sums = sum(bwImg,2);

  % find top- and bottom sums, NOT WORKING
  %top_sums = h_scanlines_sums(1:v_middle,:);
  %bottom_sums = h_scanlines_sums(v_middle:h_scanlines,:);
  %[max_top,top_line] = max(top_sums);
  %[max_bottom,bottom_line] = max(bottom_sums);
  %bottom_line = bottom_line + v_middle;

  % fill out horizontal lines outside plate with 1's (white)
  %for l = 1:top_line
  %  bwImg(l,:) = 1;
  %end

  %for l = bottom_line:size(bwImg,1)
  %  bwImg(l,:) = 1;
  %end

  % display 'cut' image, everything above and below the plate should
  % now be white
  %figure(1), subplot(3,3,2), imshow(bwImg), title('bwImg, processed');

  % calculate total no. of vertical scanlines and the pixel-sum of each line
  %v_scanlines = size(bwImg,2);
  %v_scanlines_sums = sum(bwImg,1);

  % there are 14 vertical cuts to be made, two for each of the seven chars
  %cuts = zeros(1,14);

  % whether we are going towards a char
  %to_char = true;

  %cutNo = 1;
  %char_width = 0;
  %firstchar_met = false;
  %min_char_width = 5;
  %s = 1;

  % iterate through vertical scanlines
  %while cutNo < 15
  %  % if the vertical line is all white
  %  if v_scanlines_sums(s) == size(bwImg,1)
  %    firstchar_met = true;
  %    % position: in front of a char
  %    if to_char && v_scanlines_sums(s+1) < size(bwImg,1)
  %      cuts(cutNo) = s;
  %      %s
  %      cutNo = cutNo + 1;
  %    % position: at the end of a char
  %    elseif v_scanlines_sums(s+1) == size(bwImg,1) && char_width > min_char_width
  %      cuts(cutNo) = s;
  %      %s
  %      cutNo = cutNo + 1;
  %      char_width = 0;
  %    end
  %  % position: in a char
  %  elseif firstchar_met
  %    char_width = char_width + 1;
  %  end
  %  % iterate
  %  s = s + 1;
  %end

  % add each image of a char to the struct chars (indexed by 'field1',
  % 'field2' etc.) display chars afterwards
  %plotPos = 3;
  %for c = 1:floor(cutNo/2)
  %  fieldName = strcat('field',int2str(c));
  %  chars.(fieldName) = plateImg(top_line:bottom_line,cuts(c):cuts(c+1),:);
  %  %figure(1), subplot(3,3,plotPos), imshow(chars.(fieldName)), title(fieldName);
  %  plotPos = plotPos + 1;
  %end
  
  


% find no. of black sequenses across a scanline and their startpositions
%function [blackCount, blackPositions] = findBlackCount (bwImg, lineNo)
%
%  % initiate variables
%  blackCount = 0;
%  inWhiteSeq = true;
%  blackPositions = [];
%  
%  % iterate across line
%  for p = 1:size(bwImg,2)
%    % fetch color
%    color = bwImg(lineNo,p);
%    
%    % white pixel
%    if color == 1
%      inWhiteSeq = true;
%      
%    % black pixel
%    else
%      if inWhiteSeq
%        blackCount = blackCount + 1;
%        blackPositions(blackCount) = p;
%      end
%      inWhiteSeq = false;
%    end
%    
%  end
%
%end

end
