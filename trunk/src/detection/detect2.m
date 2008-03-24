function plateCoords = detect2(inputImage)

% Downscale factor
downscaleFactor = 2;

% Size of blocks
gradBlockSize = 4;




% Read image from file
origImage = imread(inputImage);

% Convert image to grayscale
image = rgb2gray(origImage);


image = log10(double(image));
image = uint8((256/(max(max(image)))) .* image);


% Downsample image columns
image = downsample(image,downscaleFactor);
% Downsample image rows
image = transpose(downsample(transpose(image),downscaleFactor));

% Image width and height
imHeight = size(image,1);
imWidth = size(image,2);



figure(100);



% Experiment with gradients

% Calculate gradients
[gradsX,gradsY] = gradient(double(image));

% We want to use absolute values of gradients
gradsY = abs(gradsY);
gradsX = abs(gradsX);




%figure(10);
%imshow(abs(FX),[]);
%maxGradientX = max(max(abs(FX)));
%minGradientX = min(min(FX));

% Create an ampty matrix to hold summed gradients
summedGradsX = zeros(imHeight/gradBlockSize, imWidth/gradBlockSize);
%summedGradsY = zeros(imHeight, imWidth);



% Calculate image with blocks of summed gradients
for x = 1:(imWidth/gradBlockSize)
  for y = 1:(imHeight/gradBlockSize)
     y2 = (y*gradBlockSize);
     y1 = y2-gradBlockSize+1;
 
     x2 = (x*gradBlockSize);
     x1 = x2-gradBlockSize+1; 
     
     summedGradsX(y,x) = sum(sum(gradsX(y1:y2,x1:x2)));
     summedGradsY(y,x) = sum(sum(gradsY(y1:y2,x1:x2)));

  end
end


% Normalize image of summed gradients
summedGradsXNorm = summedGradsX./max(max(summedGradsX));
summedGradsYNorm = summedGradsY./max(max(summedGradsY));




% Convert strongest

summedGradsXThresh = im2bw(summedGradsXNorm,0.50);
summedGradsYThresh = im2bw(summedGradsYNorm,0.50);

 
%summedGradsXThresh = zeros(size(summedGradsXNorm,1), size(summedGradsXNorm,2));
%for x = 1:size(summedGradsXThresh,2)
%  for y = 1:size(summedGradsXThresh,1)
%    if (summedGradsXNorm(y,x) > 0.35)
%      summedGradsXThresh(y,x) = 1;
%    end 
%  end
%end






% Dilate to make components in plate connect
%Shape to use for dilation
%line = strel('line',3,0);
%line = strel('line',10,2);
%line = strel('line',10,5);
%line = strel('line',6,22);
%ball = strel('ball',2,2);
%square = strel('square',4);
%se = strel('disk',2,4);
shape = strel('rectangle',[2,4]);

%vertHorGrads = imdilate(vertHorGrads,square);
summedGradsXThresh = imdilate(summedGradsXThresh,shape);
summedGradsYThresh = imdilate(summedGradsYThresh,shape);


% Create binary image showing only areas with high vert and hori gradients
vertHorGrads = and(summedGradsXThresh, summedGradsYThresh);




% Lets find out which connected component in the image has the most
% plate-like width/height ratio 504/120 is official size

%optimalPlateRatio = 504/120;

optimalPlateRatio = 604/120;

% conComp = matrix holding components
% numConComp = Number of connected components
[conComp,numConComp] = (bwlabel(vertHorGrads,8));

% Loop through connected components. The component with the
% best width/height-aspect is our numberplate

% smallest diff between best components ratio and optimal plate ratio
bestRatioDiff = inf;

% The number of the component with the closest matchin aspect ratio
bestRatioComponent = 0;


for i = 1:numConComp
  
  % Get Xs and Ys of current component
  [Ys,Xs] = find(conComp == i);

  % Calculate width/height-ratio of current component
  compRatio = (max(Xs)-min(Xs))/(max(Ys)-min(Ys));

  % Calculate difference between current components ratio
  % and ratio of plate
  ratioDiff = abs(optimalPlateRatio-compRatio);

  if ratioDiff < bestRatioDiff
    bestRatioDiff = ratioDiff;
    bestRatioComponent = i;
  end

end


% Get coords for best matching component
[Ys,Xs] = find(conComp == bestRatioComponent);

% Calculate coords
minX = downscaleFactor*gradBlockSize*min(Xs);
maxX = downscaleFactor*gradBlockSize*max(Xs);
minY = downscaleFactor*gradBlockSize*min(Ys);
maxY = downscaleFactor*gradBlockSize*max(Ys);


%bestRatioComponent
bestRatioDiff



%%%%%%%%%%%%%%%%%%%%
% Plots            %
%%%%%%%%%%%%%%%%%%%%

% Image
subplot(2,3,1);
imshow(vertHorGrads);
%imshow(image);


% Gradients
subplot(2,3,2);
imshow(gradsX,[]);
subplot(2,3,3);
imshow(origImage(minY:maxY,minX:maxX),[]);

%imshow(gradsY,[]);

% Summed gradients
subplot(2,3,4);
imshow(summedGradsXNorm);


% Summed grads as binary image
subplot(2,3,5);
imshow(summedGradsXThresh);


subplot(2,3,6);
imshow(summedGradsYThresh);



plateCoords = [1 2 3 4];

end 
