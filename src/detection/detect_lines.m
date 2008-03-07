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

% Log image
%image = log10(double(image))/log10(512);
%image = log(double(image));

% Detect edges in image
%image = edge(image,'roberts',0.1); 
%image = edge(image,'roberts'); 
image = edge(image); 

% Get connected components in image
% conComp = matrix holding components
% numConComp = Number of connected components
[conComp,numConComp] = (bwlabel(image,8));

figure(1);
imshow(image);

% Delete connected components smaller than than X
maxCompSize = 2;
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

figure(2);
imshow(image);



%figure(2);
%imshow(L);


%figure, imshow(edge(image,'roberts',10));


plateImage = 0;
return;
