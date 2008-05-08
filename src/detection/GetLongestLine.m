% Takes an image as input, and returns the length of the longest
% bright horizontal line in the image as a percentage of the image width.

function longestLine = GetLongestLine(inputImage)

  %showImages = true;
  showImages = false;

  contrastImage = ContrastStretch(inputImage,0);
 
  % Convert input image to binary
  binImage = im2bw(contrastImage, graythresh(contrastImage));

  % Get height and width of input image 
  [imHeight, imWidth] = size(binImage);

  % The longest bright horizontal line in the image
  longestLine = 0;

  

  % Go through image
  for y = 1:imHeight

    % Length of current white line
    thisLineLength = 0;

    for x = 1:imWidth

      if binImage(y,x) == 1
        % Current pixel is white
        thisLineLength = thisLineLength + 1;
      else
        % We found a black pixel
        if thisLineLength > longestLine
          % Update longest line in image if
          % just ended is longer
          longestLine = thisLineLength;
        end
        % New line starts
        thisLineLength = 0;
      end

    end % End row

    % Row has ended. Is the last line longer than the longest so far?
    if thisLineLength > longestLine
      longestLine = thisLineLength;
    end

  end % End columns

  % Convert longest line to percentage
  longestLine = uint8((100/imWidth) * longestLine); 
  

  if showImages
    figure(130);

    % Original image
    subplot(1,3,1);
    imshow(inputImage);

    % Contrast stretched image
    subplot(1,3,2);
    imshow(contrastImage);

    % Binary image
    subplot(1,3,3);
    imshow(binImage);

  end

end
