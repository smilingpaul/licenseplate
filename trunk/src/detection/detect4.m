% Finds 51.5% of all plates fed
% If function returns coordinates correctness is 88%

% UPDATE
% Brightening the image but stil using logimage 
% improves results to 59.7% and 88.7% respectively
% Only using brightened image brings results down to 25.7% and 59.5%

% WHAT DOES IT DO?
% Finds highest peak in histogram and does contrast stretch


function plateCoords = detect4(inputImage)


showImages = false;
%showImages = true;


% Scale factor
scaleFactor = 0.25;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Read image from file as gray %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

origImage = rgb2gray(imread(inputImage));


%%%%%%%%%%%%%%%%
% Resize image %
%%%%%%%%%%%%%%%%

% Resize image
resizedImage = imresize(origImage, scaleFactor);


% Image width and height (It was scaled)
[imHeight, imWidth] = (size(resizedImage(:,:,1)));


%logImage = uint8(256 * (double(resizedImage) ./ 180));
%max(max( double(resizedImage) ./ 180  ))


%%%%%%%%%%%%%%%%%%%%%%%%%%
% Log image %
%%%%%%%%%%%%%%%%%%%%%%%%%%

%logImage = log10(double(scaledImage));
%logImage = uint8((256/(max(max(logImage)))) .* logImage);



% Brighten
brightenedImage = uint8(256 * (double(resizedImage) ./ 160)); %180
%brightenedImage = resizedImage;




%%%%%%%%%%%%%%%%%%%%
% Contrast stretch %
%%%%%%%%%%%%%%%%%%%%

%% Create histogram
imHist = hist(double(resizedImage(:)),256);


window = 100;


% Highest value of summed window (a lot of information in window)
bestWinVal = 1;
% Start position of best window
bestWinStart = 1;

for x = 1:(256-window)
 thisWinVal = sum(imHist(x:x+window-1)); 
 if thisWinVal > bestWinVal
   bestWinVal = thisWinVal;
   bestWinStart = x;
 end
end 


minCut = bestWinStart;
maxCut = bestWinStart + window - 1;


%{

%% Find location of highest value in histogram (peak)
histPeakPos = find(imHist >= max(imHist));
%histPeakPos = 128;

minCut = histPeakPos(1) - 60;
maxCut = histPeakPos(1) + 70;
%}



if maxCut > 256
  maxCut = 256;
end
if minCut < 1
  minCut = 1;
end




% Contrast
test1 = uint8(brightenedImage-minCut);
test2 = uint8((255+maxCut) * (double(test1) / double(max(max(test1)))));
contImage = test2;


%%%%%%%%%%%%%%%%%%%%%%%%%%% 
% Convert to binary image %
%%%%%%%%%%%%%%%%%%%%%%%%%%% 

binImage = im2bw(contImage, graythresh(contImage));


% Erode image to separate plates from cars %

%Shape to use for dilation
%line = strel('line',3,0);
%line = strel('line',10,2);
%line = strel('line',10,5);
%line = strel('line',6,22);
%ball = strel('ball',2,2);
shape = strel('square',1);
%se = strel('disk',2,4);

binImage = imerode(binImage,shape);

% dilate to make components in plate connect
shape = strel('rectangle',[1,3]);
binImage = imdilate(binImage,shape);

%contImage = imclose(contImage,shape);


% Delete small areas
binImage = bwareaopen(binImage,round(600*scaleFactor),4);




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Calculate connected components %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



% conComp = matrix holding components
% numConComp = Number of connected components
[conComp,numConComp] = (bwlabel(binImage,4));





plateCoords = GetBestCandidate(conComp, scaleFactor);


  % Make plate a little higher
  if sum(plateCoords) > 0 % Candidate exists
    if plateCoords(3) > 5 && plateCoords(4) < ((1/scaleFactor) * imHeight) -5
      plateCoords = plateCoords + [0 0 -5 5 ];
    end
  end




%%%%%%%%%%%%%%%%%%%%
% Plots            %
%%%%%%%%%%%%%%%%%%%%

if showImages
  %figure(200), imshow(label2rgb(conComp));


  figure(100);


  % Image
  subplot(2,4,1);
  imshow(resizedImage);
  title('Original');

  % brightened image
  subplot(2,4,2);
  imshow(brightenedImage);
  title('Brightened');

  % Gradients
  subplot(2,4,3);
  imshow(contImage);
  title('Contrast');


  subplot(2,4,4);
  %figure, imshow(contImage);
  imshow(binImage);
  %hist(double(contImage(:)),256)

  % Histogram orig
  subplot(2,4,5);
  hist(double(resizedImage(:)),256)
  hold on;
  plot(minCut, 10,'ro');
  plot(maxCut, 10,'ro');
  hold off; 

  %imshow(summedGradsXNorm);


  % Summed grads as binary image
  subplot(2,4,6);
  %imshow(conComp);
  hist(double(contImage(:)),256)
  %imshow(summedGradsXThresh);


  subplot(2,4,7);
  if sum(plateCoords) > 0
    imshow(origImage(plateCoords(3):plateCoords(4),plateCoords(1):plateCoords(2)),[]);
  else
    imshow(zeros(1));
  end

  %imshow(FX);
end




end 
