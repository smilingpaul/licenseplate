% Marks areas with platelike frequency

function plateCoords = DetectPlateness(inputImage)

  scaleFactor = 0.25;

  filterWidth = round(90*scaleFactor);
  filterHeight = 1;

  % Plateness pr. pixel (orig size image)
  idealPlateness = 0.093 * filterWidth * (1/scaleFactor);






  brightenValue = 180; % 256 = no brighten

  showImages = false;
  %showImages = true;






  % Read image from file
  origImage = imread(inputImage);

  % Convert image to greyscale
  grayImage = rgb2gray(origImage);

  % Resize image
  resizedImage = imresize(grayImage, scaleFactor);

  % Log image
  %logImage = log(double(grayImage));

  % Brigthen image
  %brightenedImage = uint8(256 * (double(resizedImage) ./ brightenValue));



  %%%%%%%%%%%%%%%%%%%%%%%%
  % Apply filter         %
  %%%%%%%%%%%%%%%%%%%%%%%%

  % Get image height and width
  [imHeight, imWidth] = (size(resizedImage));

  % Create empty image
  platenessImage = zeros(imHeight, imWidth);


  % Apply filter
  for y = 1:imHeight
    for x = 1:(imWidth - filterWidth)
      thisLine = resizedImage(y,x:x+filterWidth-1);
      platenessImage(y,x+round(filterWidth/2)) = abs(GetPlateness(thisLine) - idealPlateness);
    end
  end

  % Normalize (to 256) image of plateness
  platenessImage = uint8(256 * (platenessImage ./ max(max(platenessImage))));

  %%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Create binary image     %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%
  binImage = im2bw(platenessImage,graythresh(platenessImage));
  
  %Invert image
  binImage = not(binImage);

  cleanedBinImage = BinImgCleanup(binImage, scaleFactor);

  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Delete small areas        %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  % Delete areas smaller than 250 pixels
  % binImageSmall = bwareaopen(binImage,round(700*scaleFactor),4);


  %%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Dilate                   %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%

  % Erode image to separate plates from cars %
 
  %Shape to use for dilation
  %line = strel('line',3,0);
  %line = strel('line',10,2);
  %line = strel('line',10,5);
  %line = strel('line',6,22);
  %shape = strel('disk',3);
  %shape = strel('square',2);
  %se = strel('disk',2,4);

  %binImage = imerode(binImage,shape);


  % dilate to make components in plate connect
  %shape = strel('rectangle',[3,2]);
  %shape = strel('square',2);
  %binImage = imdilate(binImageSmall,shape);






  %%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Connected components     %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%

  [conComp,numConComp] = (bwlabel(cleanedBinImage,4));

  %%%%%%%%%%%%%%%%%%%%%%
  % Get best candidate %
  %%%%%%%%%%%%%%%%%%%%%%

  
  plateCoords = GetBestCandidate(conComp, scaleFactor);



  %%%%%%%%%%%%%%%
  % Images      %
  %%%%%%%%%%%%%%%

  if showImages
    figure(100);
  
    subplot(2,4,1);
    imshow(resizedImage);

    subplot(2,4,2);
    %imshow(brightenedImage);

    subplot(2,4,3);
    imshow(platenessImage);

    % Show candidate
    subplot(2,4,4);
    if sum(plateCoords) > 0
      imshow(origImage(plateCoords(3):plateCoords(4),plateCoords(1):plateCoords(2)));
    else
      imshow(zeros(2,2));
    end

    subplot(2,4,5);
    %imshow(binImage);

    %subplot(2,4,6);
    %imshow(FY);

    subplot(2,4,7);
    imshow(binImage);

    subplot(2,4,8);
    imshow(cleanedBinImage);



    %subplot(2,4,5);
    %imshow(newImage(minY:maxY,minX:maxX));

  end


  % Make plate a little higher 
  if sum(plateCoords) > 0
    plateCoords = plateCoords + [ 0 0 -5 5 ];
  end


end % function 
