function plateCords = detect2(inputImage)

% Downscale factor
downscaleFactor = 4;

% Size of blocks
gradBlockSize = 8;




% Read image from file
origImage = imread(inputImage);

% Convert image to grayscale
image = rgb2gray(origImage);


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

summedGradsXThresh = im2bw(summedGradsXNorm,0.30);
summedGradsYThresh = im2bw(summedGradsYNorm,0.30);

 
%summedGradsXThresh = zeros(size(summedGradsXNorm,1), size(summedGradsXNorm,2));
%for x = 1:size(summedGradsXThresh,2)
%  for y = 1:size(summedGradsXThresh,1)
%    if (summedGradsXNorm(y,x) > 0.35)
%      summedGradsXThresh(y,x) = 1;
%    end 
%  end
%end




% Create binary image showing only areas with high vert and hori gradients
vertHorGrads = and(summedGradsXThresh, summedGradsYThresh);


% Lets find out which connected component in the image has the most
% plate-like width/height ratio
optimalPlateRatio = 504/120;


% conComp = matrix holding components
% numConComp = Number of connected components
[conComp,numConComp] = (bwlabel(scanner,8));





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
imshow(gradsY,[]);

% Summed gradients
subplot(2,3,4);
imshow(summedGradsXNorm);


% Summed grads as binary image
subplot(2,3,5);
imshow(summedGradsXThresh);


subplot(2,3,6);
imshow(summedGradsYThresh);



plateCords = [1 2 3 4];

end 
