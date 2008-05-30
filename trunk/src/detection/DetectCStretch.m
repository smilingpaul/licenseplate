% Do contrast stretch on parts of the image

function [plateCoords candidateScore] = DetectCStretch(inputImage)

  scaleFactor = 0.25;

  filterSize = 4;


  %showImages = false;
  showImages = true;


  % Read image from file
  origImage = imread(inputImage);

  % Convert image to greyscale
  grayImage = rgb2gray(origImage);

  % Resize image
  resizedImage = imresize(grayImage, scaleFactor);


  %%%%%%%%%%%%%%%%%%%%%%%%
  % Apply filter         %
  %%%%%%%%%%%%%%%%%%%%%%%%

  % Get image height and width
  [imHeight, imWidth] = (size(resizedImage));

  % Create empty image
  filteredImage = zeros(imHeight, imWidth);


  % Apply filter
  for y = 1:imHeight/filterSize
    for x = 1:imWidth/filterSize
      thisY = 1 + (y-1) * filterSize;
      thisX = 1 + (x-1) * filterSize;
      thisBlock = ContrastStretch( ... 
                  resizedImage(thisY:thisY+filterSize-1,thisX:thisX+filterSize-1),0);
      filteredImage(thisY:thisY+filterSize-1,thisX:thisX+filterSize-1) = uint8(thisBlock);
    end
  end


  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Create binary image       %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  
  %binImage = im2bw(uint8(filteredImage),graythresh(uint8(filteredImage)));
  %binImage = im2bw(uint8(filteredImage), 0.65);
  binImage = im2bw(uint8(filteredImage), 1.2 * graythresh(filteredImage));


  %binImage = CutBridges(binImage,1);
  %pause();

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Cleanup bin image         %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  cleanedBinImage = BinImgCleanup(binImage, scaleFactor);

  %cleanedBinImage = [0];


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

  
  %plateCoords = GetBestCandidate(conComp, resizedImage, scaleFactor);
  [plateCoords, candidateScore] = GetBestCandidate2(conComp, resizedImage, scaleFactor);
  %plateCoords = [0 0 0 0];



  %%%%%%%%%%%%%%%
  % Images      %
  %%%%%%%%%%%%%%%

  if showImages
    figure(100);
  
    subplot(2,2,1);
    imshow(resizedImage);

    subplot(2,2,2);
    %imshow(uint8(filteredImage));
    imshow(binImage);


    subplot(2,2,3);
    imshow(cleanedBinImage);
    %imshow(binImage);
    %imwrite(binImage,'DetectCStrech-binary.png','PNG');

    subplot(2,2,4);
    %imshow(cleanedBinImage);

    % Show candidate
    subplot(2,2,4);
    if sum(plateCoords) > 0
      imshow(origImage(plateCoords(3):plateCoords(4),plateCoords(1):plateCoords(2)));
    else
      imshow(zeros(2,2));
    end


    %subplot(2,4,6);
    %imshow(FY);

    %subplot(2,4,7);
    %imshow(binImage);

    %subplot(2,4,8);
    %imshow(cleanedBinImage);



    %subplot(2,4,5);
    %imshow(newImage(minY:maxY,minX:maxX));

  end


  % Make plate a little higher 
  if sum(plateCoords) > 0
    plateCoords = plateCoords + [ -10 10 -10 10 ];
  end

  plateCoords = plateCoords + [ 0 0 0 0 ];


end % function 
