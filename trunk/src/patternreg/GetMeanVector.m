% Function to be used for training in a vector-based approch to character
% recognition. Analysis is made on a number of images of size N x M,
% returning a vector of length NM specifying the mean vector of the images.
%
% Input:
% - imgFolder: the folder containing the images to be processed. The images
% must be png 1-bit images.
% - height: the height that all the images should be scaled to.
% - width: the width that all the images should be scaled to.
%
% Output:
% - meanVector: the mean vector of length height x width.

function meanVector = GetMeanVector (imgFolder, height, width)


  %%%%%%%%%%%%%%%%
  % INITIALIZING %
  %%%%%%%%%%%%%%%%
  
  % whether figures should be displayed
  figuresOn = true;

  % create output vector
  meanVector = zeros(height*width,1);

  % get list of images
  imgList = dir([imgFolder '*.PNG']);
  noOfImages = length(imgList);
  
  
  %%%%%%%%%%%%%%%%%%
  % PROCESS IMAGES %
  %%%%%%%%%%%%%%%%%%

  for i = 1:noOfImages

    % read image, make it a gray image and display
    img = imread([imgFolder imgList(i).name]);

    if figuresOn
      figure(53), subplot(1,3,1), imshow(img), title('input image');
    end

    % resize image and display. TO-DO: OTHER RESIZE METHOD?
    resizedImg = imresize(img, [height width]);

    if figuresOn
      figure(53), subplot(1,3,2), imshow(resizedImg), title('resized image');
    end
    
    % sum up image in meanVector
    meanVector = meanVector + reshape(resizedImg,height*width,1);
    pause;

  end % noOfImages
  
  % take mean of summed-up vector
  meanVector = meanVector/noOfImages;
  
  % display meanVector as image
  if figuresOn
      figure(53), subplot(1,3,3), imshow(reshape(meanVector,height,width)), title('meanVector as image');
  end

end % function