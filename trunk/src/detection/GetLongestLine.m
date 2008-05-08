% Takes an image as input, and returns the length of the longest
% bright horizontal line in the image as a percentage of the image width.

function longestLine = GetLongestLine(inputImage)

  showImages = true;
 
  % Convert input image to binary
  binImage = im2bw(inputImage, graythresh(inputImage);

  % Get height and width of input image 
  [imHeight, imWidth] = size(inputImage);

  % The longest bright horizontal line in the image
  longestLine = 0;

  for x = 1:imHeight
    for y = 1:imWidth
    end
  end
   
  

  if showImages
    figure(130);

    % Original image
    subplot(2,2,1);
    imshow(inputImage);

    % Binary image
    subplot(2,2,1);
    imshow(inputImage);

  end

end
