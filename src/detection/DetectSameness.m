% Marks areas in the image based on sameness of colors
% in an rgb image. Creates binary image from that and selects component based on size

function plateCoords = DetectSameness(inputImage)


  showImages = false;
  %showImages = true;

  scaleFactor = 0.25;

  %%%%%%%%%%%%%%%%%%%%%%%%
  % Read image from file %
  %%%%%%%%%%%%%%%%%%%%%%%%

  origImage = imread(inputImage);

  % Resize image
  resizedImage = imresize(origImage, scaleFactor);
 

  % Image width and height (It was scaled)
  [imHeight, imWidth] = (size(resizedImage(:,:,1)));





  %%%%%%%%%%%%%%%%%%%%%%%%
  % Create binary image  %
  %%%%%%%%%%%%%%%%%%%%%%%%

  % create empty (binary) image
  newImage = zeros(imHeight, imWidth);

  % Loop through pixels
  for y = 1:imHeight
    for x = 1:imWidth
      avgVal = sum(resizedImage(y,x,:))/3;
      sameness = 22; %20

      if  resizedImage(y,x,1) <= avgVal+sameness && resizedImage(y,x,1) >= avgVal-sameness && ...
          resizedImage(y,x,2) <= avgVal+sameness && resizedImage(y,x,2) >= avgVal-sameness && ...
          resizedImage(y,x,3) <= avgVal+sameness && resizedImage(y,x,3) >= avgVal-sameness && ...
          avgVal > 65 % Not dark
       newImage(y,x) = 1;
    
      end 
    end
  end


  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Manipulate binary image   %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%


  % Erode to separate plates
  shape = strel('square',2);

  newImage = imerode(newImage,shape);


  % Dilate
  shape= strel('rectangle', [2,4]); % 2,5
  newImage = imdilate(newImage,shape);

  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Cleanup bin image         %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  newImage = BinImgCleanup(newImage, scaleFactor);
  %imwrite(newImage,'DetectSameness-cleaned.png','PNG');



  %%%%%%%%%%%%%%%%%%%%%%%%
  % Connected components %
  %%%%%%%%%%%%%%%%%%%%%%%%

  % conComp = matrix holding components
  % numConComp = Number of connected components
  [conComp,numConComp] = (bwlabel(newImage,4));
 
  %plateCoords = GetBestCandidate(conComp, scaleFactor);
  [plateCoords, candidateScore] = GetBestCandidate2(conComp, resizedImage, scaleFactor);


  % Make plate a little higher
  if sum(plateCoords) > 0 % Candidate exists
    if plateCoords(3) > 5 && plateCoords(4) < ((1/scaleFactor) * imHeight) -5
      plateCoords = plateCoords + [0 0 -5 5 ];
    end
  end






  %%%%%%%%%%%%%%%
  % Images      %
  %%%%%%%%%%%%%%%

  if showImages
    figure(100);
  
    % Resized image
    subplot(2,2,1);
    imshow(resizedImage);

    % Binary image
    subplot(2,2,2);
    imshow(newImage);

    % Show candidate
    if sum(plateCoords) > 0
      subplot(2,2,3);
      imshow(origImage(plateCoords(3):plateCoords(4),plateCoords(1):plateCoords(2)));
      subplot(2,2,4);
      %imshow(newImage(plateCoords(3):plateCoords(4),plateCoords(1):plateCoords(2)));
    else
      subplot(2,2,3);
      imshow(zeros(2,2));
      subplot(2,2,4);
      imshow(zeros(2,2));

    end

    % subplot(2,2,3);
    % imshow(origImage(minY:maxY,minX:maxX));



    % subplot(2,2,4);
    % imshow(newImage(minY:maxY,minX:maxX));

  end



end % function 
