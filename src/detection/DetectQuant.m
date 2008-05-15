% Filter out characters on plate. Turn down to 8 colors.
% Correctness: 63,7%/72,7% 

function plateCoords = DetectQuant(inputImage)

  scaleFactor = 0.25;

  filterSize = 8;


  showImages = false;
  %showImages = true;


  % Read image from file
  origImage = imread(inputImage);

  % Convert image to greyscale
  grayImage = rgb2gray(origImage);

  % Resize image
  resizedImage = imresize(grayImage, scaleFactor);

  % Cut down numbers of intensities to 32
  quant1Image = 8 * round(resizedImage / 8);


  %%%%%%%%%%%%%%%%%%%%%%%%
  % Apply filter         %
  %%%%%%%%%%%%%%%%%%%%%%%%

  % Get image height and width
  [imHeight, imWidth] = (size(resizedImage));

  % Create empty image
  %filteredImage = zeros(imHeight, imWidth);



  % Set pixels to max intensity of neighbourhood
  fun = @(x) max(max(x));
  filteredImage = nlfilter(quant1Image ,'indexed', [3 7], fun);

  
  % Cut down numbers of intensities to 8
  %filteredImage = round(filteredImage / 16);
  filteredImage = (floor(filteredImage / 32))+1;
 
  mDimBin = zeros(imHeight, imWidth, 16);

  % Create binary image for each color
  for y = 1:imHeight
   for x = 1:imWidth
     mDimBin(y, x, filteredImage(y,x)) = 1;
   end
  end
  
  % Cleanup each binary image
  for x = 1:16
     mDimBin(:,:,x) = BinImgCleanup(mDimBin(:,:,x), scaleFactor);
  end

  %{
  figure(800);
  for x = 1:16
    subplot(4, 4, x);
    imshow(mDimBin(:,:,x));
  end
  %}

  %filteredImage = blkproc(quant1Image, [3 3], fun);
  %filteredImage = quant1Image;

  %fun1 = @(x) ContrastStretch(x,0);
  %filteredImage1 = blkproc(filteredImage,[32 32],fun1);

  %fun1 = @(x) ContrastStretch(x,0);


  function result = synts(x)

    blah = ContrastStretch(x,0);

    result = blah(3,3);
  end

  % Sliding window contrast stretch
  %filteredImage1 = nlfilter(filteredImage, [5 5], @synts);
  filteredImage1 = filteredImage;

  %{
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
  %}

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Create binary image       %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  %Collapse binary images into one

  binImage = zeros(imHeight,imWidth);
  % We need to erode each area so that they will not
  % merge when the channels are merged
  shape = strel('square',3);
  for i = 1:16
    binImage = binImage + mDimBin(:,:,i);
    %binImage = binImage + imerode(mDimBin(:,:,i),shape);
  end

  binImage = im2bw(binImage, 0.5);
  


  %binImage = im2bw(uint8(filteredImage1),graythresh(uint8(filteredImage1)));
  %binImage = im2bw(uint8(filteredImage),graythresh(uint8(filteredImage)));
  %binImage = im2bw(uint8(filteredImage1), 0.75);


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

  %[conComp,numConComp] = (bwlabel(cleanedBinImage,4));
  %[conComp,numConComp] = (bwlabeln(mDimBin,4));
  [conComp,numConComp] = (bwlabel(cleanedBinImage,4));
  
  %%%%%%%%%%%%%%%%%%%%%%
  % Get best candidate %
  %%%%%%%%%%%%%%%%%%%%%%

  
  plateCoords = GetBestCandidate(conComp, resizedImage, scaleFactor);
  %plateCoords = [0 0 0 0];



  %%%%%%%%%%%%%%%
  % Images      %
  %%%%%%%%%%%%%%%

  if showImages
    figure(100);
  
    subplot(2,2,1);
    %imshow(resizedImage);
    imshow(quant1Image);
    %imshow(uint8(filteredImage),[]);

    subplot(2,2,2);
    %imshow(quant1Image);
    imshow(filteredImage,[]);

    subplot(2,2,3);
    %imshow(binImage);
    %imshow(uint8(filteredImage));
    %imshow(binImage);
    %imshow(label2rgb(conComp));
    imshow(cleanedBinImage);

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
    plateCoords = plateCoords + [ -10 10 -20 10 ];
  end



end % function 
