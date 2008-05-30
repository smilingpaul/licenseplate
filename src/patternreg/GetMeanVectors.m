function meanVectors = GetMeanVectors (folderFolder, vectorLength)

  % whether figures should be displayed
  figuresOn = false;

  % init meanVectors
  meanVectors = zeros(vectorLength,31);

  % folders must be:
  % 0,1,2,3,4,5,6,7,8,9,A,B,C,D,E,H,J,K,L,M,N,O,P,R,S,T,U,V,X,Y,Z
  folderList = dir(folderFolder);
  noOfFolders = length(folderList);

  % find all mean vectors and concat them
  meanVectorNo = 1;
  for i = 1:noOfFolders
    if ~isempty(regexp(folderList(i).name,'[A-Z0-9]')) && folderList(i).isdir
      imgFolder = [folderFolder folderList(i).name '/'];
      
      ['Creating meanVector for char ' folderList(i).name] 
      
      meanVector = GetMeanVector(imgFolder);
    
      meanVectors(:,meanVectorNo) = meanVector;

      meanVectorNo = meanVectorNo + 1;
      
    end
    
  end
  
  % Function to be used for training in a vector-based approch to character
  % recognition. Analysis is made on a number of images of size N x M,
  % returning a vector of length NM specifying the mean vector of the
  % images.
  function meanVector = GetMeanVector (imgFolder)

    % create output vector
    meanVector = zeros(vectorLength,1);

    % get list of images
    imgList = dir([imgFolder '*.PNG']);
    noOfImages = length(imgList);


    %%%%%%%%%%%%%%%%%%
    % PROCESS IMAGES %
    %%%%%%%%%%%%%%%%%%

    for j = 1:noOfImages

      % read image, make it a gray image and display
      img = imread([imgFolder imgList(j).name]);

      if figuresOn
        figure(53), subplot(1,3,1), imshow(img), title('input image');
      end

      % resize image and display. TO-DO: OTHER RESIZE METHOD?
      resizedImg = imresize(img, [sqrt(vectorLength) sqrt(vectorLength)]);

      if figuresOn
        figure(53), subplot(1,3,2), imshow(resizedImg), title('resized image');
      end

      % sum up image in meanVector
      meanVector = meanVector + reshape(resizedImg,vectorLength,1);
      %meanVector = meanVector + resizedImg;
      %pause;

    end % noOfImages

    % take mean of summed-up vector
    meanVector = meanVector/noOfImages;

    % display meanVector as image
    if figuresOn
        figure(53), subplot(1,3,3), imshow(resizedImg), title('meanVector as image');
    end

  end % GetMeanVector

end % GetMeanVectors