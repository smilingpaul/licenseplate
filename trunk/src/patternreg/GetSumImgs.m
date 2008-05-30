function sumImgs = GetSumImgs (folderFolder, imSize)

  % whether figures should be displayed
  figuresOn = true;

  % init meanVectors
  sumImgs = zeros(imSize,imSize,31);

  % folders must be:
  % 0,1,2,3,4,5,6,7,8,9,A,B,C,D,E,H,J,K,L,M,N,O,P,R,S,T,U,V,X,Y,Z
  folderList = dir(folderFolder);
  noOfFolders = length(folderList);

  % find all mean vectors and concat them
  sumImgNo = 1;
  for i = 1:noOfFolders
    if ~isempty(regexp(folderList(i).name,'[A-Z0-9]')) && folderList(i).isdir
      imgFolder = [folderFolder folderList(i).name '/'];
      
      ['Creating sumImg for char ' folderList(i).name] 
      
      sumImg = GetSumImg(imgFolder);
      sumImgs(:,:,sumImgNo) = sumImg;
      
      % normalize
      sumImgs(:,:,sumImgNo) = sumImgs(:,:,sumImgNo)/max(max(sumImgs(:,:,sumImgNo)));
      
      figure(53), subplot(1,3,3), imshow(sumImgs(:,:,sumImgNo));
      pause;
      
      sumImgNo = sumImgNo + 1;
      
    end
  end
  
  function sumImg = GetSumImg (imgFolder)

    % create output vector
    sumImg = double(zeros(imSize));

    % get list of images
    imgList = dir([imgFolder '*.PNG']);
    noOfImages = length(imgList);


    %%%%%%%%%%%%%%%%%%
    % PROCESS IMAGES %
    %%%%%%%%%%%%%%%%%%

    for j = 1:noOfImages

      % read image, make it a gray image and display
      img = imread([imgFolder imgList(j).name]);

      % resize image and display. TO-DO: OTHER RESIZE METHOD?
      resizedImg = imresize(img, [imSize imSize]);

      % sum up image in meanVector
      sumImg = sumImg + double(resizedImg);
      %meanVector = meanVector + resizedImg;
      if figuresOn
        %figure(53), subplot(1,3,1), imshow(resizedImg), title('resized image');
        %figure(53), subplot(1,3,2), imshow(sumImg), title('sumImg');
      end

    end % noOfImages

  end % GetSumImg

end % GetSumImgs