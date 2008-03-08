function plateImage = detect_lines(inputImage)

% Downscale factor
downscaleFactor = 4;

% Read image from file
image = imread(inputImage);

% Convert image to grayscale
image = rgb2gray(image);


% Downsample image columns
image = downsample(image,downscaleFactor);
% Downsample image rows
image = transpose(downsample(transpose(image),downscaleFactor));

% Image width and height
imHeight = size(image,1);
imWidth = size(image,2);




% Experiment with gardients
[FX,FY] = gradient(double(image));
%figure(10);
%imshow(abs(FX),[]);
maxGradientX = max(max(abs(FX)));
%minGradientX = min(min(FX));

% Create an empty matrix with same dimensions as image
scanner = zeros(imHeight, imWidth);


for x = 1:imWidth
  for y = 1:imHeight
    if abs(FX(y,x)) > (maxGradientX * 0.5)
      scanner(y,x) = 1;
    end  
  end
end

% Show image with only strong gradients marked
%figure(1) , imshow(scanner);


% Find value of most white (largest sum) horizontal line
rowWhiteValues = sum(transpose(scanner));
maxRowWhiteValue = max(rowWhiteValues);


% Set all values for rows with low white-values to 0
for row  = 1:imHeight
  if (rowWhiteValues(row) < (0.7 * maxRowWhiteValue))
    scanner(row,:) = 0;
  end 
end

% Show image with weak lines removed
%figure(15) , imshow(scanner);


figure(100);
subplot(1,2,1);
imshow(scanner);
subplot(1,2,2);
imshow(image);

% Show original image
% figure(18) , imshow(image);


image = scanner;




%Shape to use for erosion
%se = strel('square',1);
%figure(20), imshow(imerode(scanner,se),[]);
%figure(30), imshow(scanner,[]);


%imshow(edge(FX,'roberts',2.5));
%figure(20);
%imshow(FY,[]);




% Log image
%image = log10(double(image))/log10(512);
%image = log(double(image));

% Detect edges in image
%image = edge(image,'roberts',0.1); 
%image = edge(image,'roberts'); 
%image = edge(image,'sobel'); 
%image = edge(image); 

% Get connected components in image
% conComp = matrix holding components
% numConComp = Number of connected components
[conComp,numConComp] = (bwlabel(image,8));

%figure(1);
%imshow(image);

% Delete connected components smaller than than X
maxCompSize = 1;
for i = 1:numConComp
%for i = 1:100
  % If current component is smaller than X
  compLength = length(find(conComp == i));
  if compLength <= maxCompSize
    % get coordinates of pixels in component
    [x,y] = find(conComp == i);
    % Set color of pixels in component
    for j = 1:compLength
      % 0 = black
      image(x(j), y(j)) = 0;
    end
  end
end

% Find biggest connected component 

%figure(2);
%imshow(image);



%figure(2);
%imshow(L);


%figure, imshow(edge(image,'roberts',10));


plateImage = 0;
return;
