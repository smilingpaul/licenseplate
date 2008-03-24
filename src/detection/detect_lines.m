function plateCords = detect_lines(inputImage)

% Downscale factor
downscaleFactor = 2;



% get candidate coordinate from detect4
d4C = detect4(inputImage) ./ downscaleFactor;

% Read image from file
origImage = imread(inputImage);




% Convert image to grayscale
image = rgb2gray(origImage);




% Brighten image
%brighten(1);


% Log image
image = log10(double(image));
image = uint8((256/(max(max(image)))) .* image);


%image = image - 100;

%image = double(max(max(image))) ./ double(image);

%image = image .* 256;


%max(max(image))
%min(min(image))

%figure, imshow(image,[]);





% Downsample image columns
image = downsample(image,downscaleFactor);
% Downsample image rows
image = transpose(downsample(transpose(image),downscaleFactor));


% Image width and height
imHeight = size(image,1);
imWidth = size(image,2);








figure(100);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Create image of strongest gradients         %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Experiment with gradients
[FX,FY] = gradient(double(image));
%figure(10);
%imshow(abs(FX),[]);
maxGradientX = max(max(abs(FX)));
%minGradientX = min(min(FX));

% Create an empty matrix with same dimensions as image
scanner = zeros(imHeight, imWidth);


for x = 1:imWidth
  for y = 1:imHeight
%    if abs(FX(y,x)) > (maxGradientX * 0.5)
    if abs(FX(y,x)) > (maxGradientX * 0.2)
      scanner(y,x) = 1;
    end  
  end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Delete connected components smaller than than X %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Get connected components in image
% conComp = matrix holding components
% numConComp = Number of connected components
[conComp,numConComp] = (bwlabel(scanner,8));
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
      scanner(x(j), y(j)) = 0;
    end
  end
end




% Show image with only strong gradients marked
%figure(1) , imshow(scanner);

% Strongest gradients
subplot(3,2,3);
imshow(scanner);

%subplot(3,2,6);
%imshow(imfill(~scanner,'holes'));


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Dilate image of strongest gradients %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Shape to use for dilation
%line = strel('line',6,0);

%shape = strel('line',10,2); % Den gamle


%line = strel('line',10,5);
%line = strel('line',6,22);
%ball = strel('ball',1,1);
%shape = strel('square',3);
%se = strel('disk',2,4);

shape= strel('rectangle', [3,10]); % For scale = 2
%shape= strel('rectangle', [2,5]); % for scale = 4

%scanner = imdilate(scanner,ball);
scanner = imdilate(scanner,shape);
%scanner = imerode(scanner,se);

% Show dilated image
subplot(3,2,4);
imshow(scanner);
% Show eroded image
subplot(3,2,5);
%imshow(imerode(scanner,se));

%Show components in dilated image

% Show connected components as colors
%imshow(label2rgb(bwlabel(scanner)));


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Do stuff to components %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Create components
[conComp,numConComp] = (bwlabel(scanner,4));

% Loop through componets
for i = 1:numConComp
  % Get Xs and Ys of current component
  [Ys,Xs] = find(conComp == i);
  compHeight = max(Ys)-min(Ys)+1;
  compWidth = max(Xs)-min(Xs)+1;
  ratio = compHeight/compWidth;
%  if (ratio > 0.3 || ratio < 0.12 || compHeight < 4)
  if (ratio > 0.35 || ratio < 0.12 || compHeight < 4)
    for j = 1:length(Ys)
      scanner(Ys(j),Xs(j)) = 0;
    end
  end
end

% Show image after having manipulated components
subplot(3,2,6);
imshow(scanner);



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% REMOVING LEAST WHITE LINES %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Not effectice % REMOVED %

% Find value of most white (largest sum) horizontal line
%rowWhiteValues = sum(transpose(scanner));
%maxRowWhiteValue = max(rowWhiteValues);

% Set all values for rows with low white-values to 0
%for row  = 1:imHeight
%  if (rowWhiteValues(row) < (0.2 * maxRowWhiteValue))
%    scanner(row,:) = 0;
%  end 
%end

% Show image with weak lines removed
%figure(15) , imshow(scanner);



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CONSIDER DOING A DILATE HERE TO GET THE WHOLE PLATE %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Shape to use for dilation
%shape = strel('line',15,22);

%line = strel('line',10,2);
%line = strel('line',10,5);
%line = strel('line',6,22);
%shape = strel('ball',3,3);
%shape = strel('square',4);
%shape = strel('square',4);
%se = strel('disk',2,4);

shape = strel('rectangle', [10,6]); % For scale = 2
%shape = strel('rectangle', [5,3]); % For scale = 4

scanner = imdilate(scanner,shape);

% Instead of dilating here, I'll return parts of the
% image below and over the component when calculation coordinates
% Hmm.. But then I'd need to take care of coords outside the image

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Use biggest component to get plate position %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% If more than one candidate. The one closest to the center should win.
% Or beeing close to the edge is not good
% Another posibility is choosing the area with the most plate like ratio


% Create components
[conComp,numConComp] = (bwlabel(scanner,4));

% Loop through componets
%biggestComponent = 0;
biggestComponentSize = 0;

% Need to set these for cases with no candidates
topLeft = [1,1];
topRight = [1,1];
bottomLeft = [1,1];
bottomRight = [1,1];    


% Check if one of our candidates includes the
% center of detect4's canditate
if sum(d4C) > 0 
  d4Thinks = conComp(round(sum(d4C(3:4))/2),round(sum(d4C(1:2))/2)) 
else
  d4Thinks = 0
end


if d4Thinks > 0
  % d4 has a candidate which is also one of our
  % candidates. Let's return d4s coordinates
  % as its candidates are well-sized
  topLeft = downscaleFactor*[d4C(3),d4C(1)];
  topRight = downscaleFactor*[d4C(3),d4C(2)];
  bottomLeft = downscaleFactor*[d4C(4),d4C(1)];
  bottomRight = downscaleFactor*[d4C(4),d4C(2)];    

else
  for i = 1:numConComp
    % Get Xs and Ys of current component
    [Ys,Xs] = find(conComp == i);
    % Get size of component
    compSize = length(Xs);

    if (compSize > biggestComponentSize && min(Ys) > 5 && ...
        max(Ys) < imHeight-5 && min(Xs) > 5 && ... 
        max(Xs) < imWidth-5 )
      %biggestComponent = i;
      biggestComponentSize = compSize;
      topLeft = downscaleFactor*[min(Ys),min(Xs)];
      topRight = downscaleFactor*[min(Ys),max(Xs)];
      bottomLeft = downscaleFactor*[max(Ys),min(Xs)];
      bottomRight = downscaleFactor*[max(Ys),max(Xs)];    
    end % component
  end % component loop
end % d4Thinks


% If detected area does not match ratio of plate. Consider making it wider.



subplot(3,2,5);
%imshow(scanner);
imshow(origImage([topLeft(1):bottomLeft(1)],[topLeft(2):topRight(2)]));
%imshow(image([topLeft:bottomLeft],[1:200]));
%imshow(image([1:50],[1:200]));


% Weak lines removed
subplot(3,2,1);
imshow(scanner);

% Original image
subplot(3,2,2);
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





% Detect edges in image
%image = edge(image,'roberts',0.1); 
%image = edge(image,'roberts'); 
%image = edge(image,'sobel'); 
%image = edge(image); 


%figure(1);
%imshow(image);


% Find biggest connected component 

%figure(2);
%imshow(image);



%figure(2);
%imshow(L);


%figure, imshow(edge(image,'roberts',10));




plateCords = [topLeft(2), topRight(2), topLeft(1), bottomLeft(1)];


return;
