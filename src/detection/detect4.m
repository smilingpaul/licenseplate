% Finds 51.5% of all plates fed
% If function returns coordinates correctness is 88%

% UPDATE
% Brightening the image but stil using logimage 
% improves results to 59.7% and 88.7% respectively
% Only using brightened image brings results down to 25.7% and 59.5%

% WHAT DOES IT DO?
% Finds highest peak in histogram and removes all intensities
% not around the value of the peak from the image



function plateCoords = detect4(inputImage)


showImages = false;
%showImages = true;


% Downscale factor
downscaleFactor = 4;










%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Read image from file as gray %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

origImage = rgb2gray(imread(inputImage));


%%%%%%%%%%%%%%%%%%%%
% Downsample image %
%%%%%%%%%%%%%%%%%%%%

% Downsample image columns
scaledImage = downsample(origImage,downscaleFactor);
% Downsample image rows
scaledImage = transpose(downsample(transpose(scaledImage),downscaleFactor));

% Image width and height
imHeight = size(scaledImage,1);
imWidth = size(scaledImage,2);




logImage = uint8(256 * (double(scaledImage) ./ 180));
max(max( double(scaledImage) ./ 180  ))
%scaledImage = uint8(256 * (double(scaledImage) ./ 180));

%%%%%%%%%%%%%%%%%%%%%%%%%%
% Log image %
%%%%%%%%%%%%%%%%%%%%%%%%%%

%logImage = log10(double(scaledImage));
%logImage = uint8((256/(max(max(logImage)))) .* logImage);



%bwImage = im2bw(logImage);


%%%%%%%%%%%%%%%%%%%%
% Contrast stretch %
%%%%%%%%%%%%%%%%%%%%


% Create histogram
imHist = hist(double(logImage(:)),256);

% Find highest location of highest value in histogram
histPeakPos = find(imHist >= max(imHist));

minCut = histPeakPos - 30;
maxCut = histPeakPos + 10;

if maxCut >= 256
  maxCut = 256;
end


%histPeakPos/255

%contImage = im2bw(logImage,histPeakPos/256);

contImage = logImage;
%contImage = scaledImage;



for row  = 1:imHeight
  for col = 1:imWidth
   if (contImage(row,col) <= minCut)
     contImage(row,col) = 0;
   elseif (contImage(row,col) >= maxCut)
     contImage(row,col) = 255;
   else
     %contImage(row,col) = (256-1) * ((contImage(row,col) - minCut)/(maxCut-minCut))
   end
  end 
end

%figure(200), imshow(im2bw(contImage));





%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Erode image to separate plates from cars %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Erode to make components in plate connect
%Shape to use for dilation
line = strel('line',3,0);
%line = strel('line',10,2);
%line = strel('line',10,5);
%line = strel('line',6,22);
%ball = strel('ball',2,2);
%shape = strel('square',2);
%se = strel('disk',2,4);

%contImage = imerode(contImage,shape);
%contImage = imclose(contImage,shape);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Calculate connected components %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%





% conComp = matrix holding components
% numConComp = Number of connected components
[conComp,numConComp] = (bwlabel(contImage,4));


% Delete some components

% Components with width og height = the image





% Lets find out which connected component in the image has the most
% plate-like width/height ratio 504/120 is official size

%optimalPlateRatio = 504/120; % 55%


% Ratio from image
%optimalPlateRatio = 182/37; % 56,7%
optimalPlateRatio = 182/42; % 57,3%



% Loop through connected components. The component with the
% best width/height-aspect is our numberplate

% smallest diff between best components ratio and optimal plate ratio
bestRatioDiff = inf;

% The number of the component with the closest matchin aspect ratio
bestRatioComponent = 0;

% If no component is chosen, well return this

%minX = 0;
%maxX = 0;
%minY = 0;
%maxY = 0;


for i = 1:numConComp
  
  % Get Xs and Ys of current component
  [Ys,Xs] = find(conComp == i);

  % Calculate with height of component
  compHeight = max(Ys)-min(Ys);
  compWidth = max(Xs)-min(Xs);
  compLength = length(Xs);

  % Calculate width/height-ratio of current component
  compRatio = compWidth/compHeight;

  % Very big components are bad
  %if compHeight < imHeight/4 && compWidth < imWidth/4

  % The sizes of the plates are smaller than this (numbers are unscaled sizes)
  if compHeight < 80/downscaleFactor && compHeight > 30/downscaleFactor && ...
      compWidth < 250/downscaleFactor && compWidth > 130/downscaleFactor && ...
      compLength >= 250 % Component should consist of a min number of fixels
  
    % compLength
    % Calculate difference between current components ratio
    % and ratio of plate
    ratioDiff = abs(optimalPlateRatio-compRatio);

    if ratioDiff < bestRatioDiff && ((max(Xs)-min(Xs))*downscaleFactor) > 20
      bestRatioDiff = ratioDiff;
      bestRatioComponent = i;
    end
  end
end


% Get coords for best matching component
[Ys,Xs] = find(conComp == bestRatioComponent);

% Calculate coords
minX = downscaleFactor*min(Xs);
maxX = downscaleFactor*max(Xs);
minY = downscaleFactor*min(Ys);
maxY = downscaleFactor*max(Ys);











%%%%%%%%%%%%%%%%%%%%
% Plots            %
%%%%%%%%%%%%%%%%%%%%

if showImages
  figure(200), imshow(label2rgb(conComp));


  figure(100);


  % Image
  subplot(2,3,1);
  imshow(scaledImage);
%imshow(image);


  % Gradients
  subplot(2,3,2);
  imshow(logImage);

  subplot(2,3,3);
  %figure, imshow(contImage);
  imshow(contImage);

  % Summed gradients
  subplot(2,3,4);
  hist(double(logImage(:)),256)

  %imshow(summedGradsXNorm);


  % Summed grads as binary image
  subplot(2,3,5);
  imshow(conComp);
  %hist(double(scaledImage(:)),256)
  %imshow(summedGradsXThresh);


  subplot(2,3,6);
  if bestRatioDiff < inf
    imshow(origImage(minY:maxY,minX:maxX),[]);
  end

  %imshow(FX);
end

if bestRatioDiff < inf
  plateCoords = [(minX-10) (maxX+10) (minY-10) (maxY+10)];
else
  % No component was selected but we need to return something
  plateCoords = [ 0 0 0 0 ];
end



end 
