function andImgs = GetAndImgs (folderFolder, imSize)

  % whether figures should be displayed
  figuresOn = false;

  % init meanVectors
  andImgs = zeros(imSize,imSize,31);

  % folders must be:
  % 0,1,2,3,4,5,6,7,8,9,A,B,C,D,E,H,J,K,L,M,N,O,P,R,S,T,U,V,X,Y,Z
  folderList = dir(folderFolder);
  noOfFolders = length(folderList);

  % find all mean vectors and concat them
  andImgNo = 1;
  for i = 1:noOfFolders
    if ~isempty(regexp(folderList(i).name,'[A-Z0-9]')) && folderList(i).isdir
      imgFolder = [folderFolder folderList(i).name '/'];
      
      ['Creating andImg for char ' folderList(i).name] 
      
      andImg = GetAndImg(imgFolder);
      andImgs(:,:,andImgNo) = andImg;
      andImgNo = andImgNo + 1;
      
    end
    
  end
  
  function andImg = GetAndImg (imgFolder)

    % create output vector
    andImg = ones(imSize);

    % get list of images
    imgList = dir([imgFolder '*.PNG']);
    noOfImages = length(imgList);


    %%%%%%%%%%%%%%%%%%
    % PROCESS IMAGES %
    %%%%%%%%%%%%%%%%%%

    for j = 1:noOfImages

      % read image, make it a gray image and display
      img = imread([imgFolder imgList(j).name]);

      %if figuresOn
      %  figure(53), subplot(1,3,1), imshow(img), title('input image');
      %end

      % resize image and display. TO-DO: OTHER RESIZE METHOD?
      resizedImg = imresize(img, [imSize imSize]);

      % sum up image in meanVector
      andImg = andImg & resizedImg;
      %meanVector = meanVector + resizedImg;
      if figuresOn
        figure(53), subplot(1,2,1), imshow(resizedImg), title('resized image');
        figure(53), subplot(1,2,2), imshow(andImg), title('andImg');
      end

    end % noOfImages
    
    %pause;

    % take mean of summed-up vector
    %meanVector = meanVector/noOfImages;

    % display meanVector as image
    %if figuresOn
    %    figure(53), subplot(1,3,3), imshow(resizedImg), title('meanVector as image');
    %end

  end % GetAndImg

end % GetAndImgs