% Marks areas with avg. intensity of surroundings

function [plateCoords candidateScore] = DetetctContrastAvg(inputImage)

  filterWidth = 7;
  filterHeight = 2;

  brightenValue = 180; % 256 = no brighten
  %brightenValue = 256; % 256 = no brighten

  showImages = false;
  %showImages = true;

  scaleFactor = 0.25;





  % Read image from file
  origImage = imread(inputImage);

  % Convert image to greyscale
  grayImage = rgb2gray(origImage);

  % Resize image
  resizedImage = imresize(grayImage, scaleFactor);

  % Get image height and width
  [imHeight, imWidth] = (size(resizedImage));


  % Log image
  logImage = log(double(grayImage));


  % Brigthen image
  brightenedImage = uint8(256 * (double(resizedImage) ./ brightenValue));


  % Calculate gradient images
  [FX,FY] = gradient(double(brightenedImage));

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Calculate angles of gradients %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  % Angles are between 0 (horizontal) and 90 (vertical)

  % Matrix to hold gradient angles
  gradAngles = zeros(imHeight, imWidth);

  for y = 1:imHeight
    for x = 1:imWidth
      gradAngles(y,x) = abs(atand(FY(y,x)/FX(y,x)));
    end
  end


  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Calculate length of gradients %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  % Matrix to hold gradient lengths
  gradLengths = zeros(imHeight, imWidth);

  for y = 1:imHeight
    for x = 1:imWidth
      gradLengths(y,x) = sqrt( FY(y,x)^2 + FX(y,x)^2 );
    end
  end

  % Normalize gradient lengths
  gradLengths = gradLengths / max(max(gradLengths));


  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Isolate longest gradients %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  % Matrix to hold gradient lengths
  longestGrads = zeros(imHeight, imWidth);

  for y = 1:imHeight
    for x = 1:imWidth
      if gradLengths(y,x) >= 0.25
        longestGrads(y,x) = gradLengths(y,x);
      end
    end
  end


  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Isolate vertical and horizontal gradients %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  % Matrix to hold vertical and horizontal gradients
  gradsVertHori = zeros(imHeight, imWidth);

  for y = 1:imHeight
    for x = 1:imWidth
      %if gradAngles(y,x) <= 5 || gradAngles(y,x) >= 85
      if gradAngles(y,x) <= 30
        gradsVertHori(y,x) = gradLengths(y,x);
        if gradsVertHori(y,x) >= 0.25
          % Boost if long gradient
          gradsVertHori(y,x) = 2.0 * gradsVertHori(y,x);
        end
      end
    end
  end



  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Blur horizontal gradients %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%


  % Set pixels to max intensity of neighbourhood
  fun = @(x) 0.8 * mean(mean(x));
  filteredGradients = nlfilter(gradsVertHori ,'indexed', [3 7], fun);




  %%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Create binary image     %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%
  binImage = im2bw(filteredGradients, 0.5 * graythresh(filteredGradients));


  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Cleanup bin image         %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  binImageCleaned = BinImgCleanup(binImage, scaleFactor);



  %%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Connected components     %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%

  [conComp,numConComp] = (bwlabel(binImageCleaned,4));

  %%%%%%%%%%%%%%%%%%%%%%
  % Get best candidate %
  %%%%%%%%%%%%%%%%%%%%%%

  %plateCoords = GetBestCandidate(conComp, resizedImage, scaleFactor);
  [plateCoords, candidateScore] = GetBestCandidate2(conComp, resizedImage, scaleFactor);

  % Make plate a little higher as we get very flat plates (only the characters)
  if sum(plateCoords) > 0
    %plateCoords = plateCoords + [-15 15 0 0 ];
    plateCoords = plateCoords + [ 0 0 -15 15 ];
  end


  %%%%%%%%%%%%%%%
  % Images      %
  %%%%%%%%%%%%%%%

  if showImages
    figure(100);
  
    subplot(2,4,1);
    imshow(resizedImage);
    title('Original image');

    subplot(2,4,2);
    imshow(gradLengths,[]);
    title('Length of gradients');
  
    subplot(2,4,3);
    imshow(longestGrads,[]);
    title('Longest gradients');

    subplot(2,4,4);
    imshow(gradsVertHori,[]);
    title('Horizontal gradients');



    % Show candidate
   subplot(2,4,8);
    if sum(plateCoords) > 0
      imshow(origImage(plateCoords(3):plateCoords(4),plateCoords(1):plateCoords(2)));
    else
      imshow(zeros(2,2));
    end


    subplot(2,4,5);
    imshow(filteredGradients,[]);
    title('Blurred gradients');

    % Binary image
    subplot(2,4,6);
    imshow(binImage);
    title('Blurred gradients to binary');


    subplot(2,4,7);
    imshow(binImageCleaned);
    title('Cleaned binary image');
    %imwrite(binImageCleaned,'DetectContrastAvg-cleaned.png','PNG');



  end % Show images



end % function 
