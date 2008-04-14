% Marks areas with avg. intensity of surroundings

function plateCoords = detect6(inputImage)

  filterWidth = 7;
  filterHeight = 2;

  brightenValue = 180; % 256 = no brighten

  showImages = false;
  %showImages = true;

  scaleFactor = 0.25;





  % Read image from file
  origImage = imread(inputImage);

  % Convert image to greyscale
  grayImage = rgb2gray(origImage);

  % Resize image
  resizedImage = imresize(grayImage, scaleFactor);

  % Log image
  logImage = log(double(grayImage));

  % Brigthen image
  brightenedImage = uint8(256 * (double(resizedImage) ./ brightenValue));


  % Calculate gradient images
  [FX,FY] = gradient(double(brightenedImage));
 
  % Convert gradients to absolute values
  FX = abs(FX);
  FY = abs(FY);

  % Normalize gradient images
  FX = uint8(255 * (FX ./ max(max(FX))));
  FY = uint8(255 * (FY ./ max(max(FY))));

  %%%%%%%%%%%%%%%%%%%%%%%%
  % Apply filter         %
  %%%%%%%%%%%%%%%%%%%%%%%%

  % Get image height and width
  [imHeight, imWidth] = (size(resizedImage))

  % Create empty image
  filteredGradients = zeros(imHeight, imWidth);
  %newImageY = zeros(imHeight, imWidth);


  % Apply filter
  for y = filterHeight:imHeight-filterHeight
    for x = filterWidth:imWidth-filterWidth
      %newImageY(y,x) = round(sum(sum(FY(y:y+filterHeight-1,x:x+filterWidth-1))) / (filterWidth*filterHeight));
      filteredGradients(y,x) = round(sum(sum(FX(y:y+filterHeight-1,x:x+filterWidth-1))) / (filterWidth*filterHeight));
    end
  end

  % Normalize (to 256) filtered gradients
  filteredGradients = uint8(256 * (filteredGradients ./ max(max(filteredGradients))));

  %%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Create binary image     %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%
  binImage = im2bw(filteredGradients,graythresh(filteredGradients));


  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Delete small areas        %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  % Delete areas smaller than 250 pixels
  binImageSmall = bwareaopen(binImage,250,4);




  %%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Connected components     %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%

  [conComp,numConComp] = (bwlabel(binImageSmall,4));

  %%%%%%%%%%%%%%%%%%%%%%
  % Get best candidate %
  %%%%%%%%%%%%%%%%%%%%%%

  
  plateCoords = GetBestCandidate(conComp, scaleFactor);


  % Make plate a little higher 
  if sum(plateCoords) > 0
    plateCoords + + [-5 5 0 0 ];
  end


  %%%%%%%%%%%%%%%
  % Images      %
  %%%%%%%%%%%%%%%

  if showImages
    figure(100);
  
    subplot(2,4,1);
    imshow(resizedImage);

    subplot(2,4,2);
    imshow(brightenedImage);

    subplot(2,4,3);
    imshow(filteredGradients);

    % Show candidate
    subplot(2,4,4);
    if sum(plateCoords) > 0
      imshow(origImage(plateCoords(3):plateCoords(4),plateCoords(1):plateCoords(2)));
    else
      imshow(zeros(2,2));
    end

    subplot(2,4,5);
    imshow(FX);

    %subplot(2,4,6);
    %imshow(FY);

    subplot(2,4,7);
    imshow(binImage);

    subplot(2,4,8);
    imshow(binImageSmall);



    %subplot(2,4,5);
    %imshow(newImage(minY:maxY,minX:maxX));

  end



end % function 
