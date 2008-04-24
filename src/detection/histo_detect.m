% function to detect a plate in an image using the 'histrogram method'. The
% frequency table must be constructed before this function is run
function plateCoords = histo_detect(imgFile, horizontalTable, verticalTable, figuresOn)

  scaleFactor = 0.25;

  % read image from file and display it
  img = imread(imgFile);
  %img = imresize(img,0.1);
  if figuresOn
    figure(33), subplot(3,3,1), imshow(img), title('original');
  end
  
  % downscalefactor
  %downscaleFactor = 4;
  
  % Downsample image columns
  %img = downsample(img,downscaleFactor);
  % Downsample image rows
  %img = transpose(downsample(transpose(img),downscaleFactor));
  %figure(1), subplot(2,2,2), imshow(img);
  
  % get image dimensions
  imgHeight = size(img,1);
  imgWidth = size(img,2);
  
  % the membership image contains the frequncy value for every pixel. If
  % the value is high, the pixel is likely part of a licenseplate
  membershipImg = zeros(imgHeight,imgWidth);
  
  % fill out values in membership image
  for i = 1:imgHeight-1
    for j = 1:imgWidth-1
      
      % NEW METHOD
      r = floor(double(img(i,j,1))/16)+1;
      g = floor(double(img(i,j,2))/16)+1;
      b = floor(double(img(i,j,3))/16)+1;
      
      rRight = floor(double(img(i,j+1,1))/16)+1;
      gRight = floor(double(img(i,j+1,2))/16)+1;
      bRight = floor(double(img(i,j+1,3))/16)+1;
       
      rBelow = floor(double(img(i+1,j,1))/16)+1;
      gBelow = floor(double(img(i+1,j,2))/16)+1;
      bBelow = floor(double(img(i+1,j,3))/16)+1;
      
      membershipImg(i,j) = ...
        horizontalTable(r,g,b,rRight,gRight,bRight) + ...
        verticalTable(r,g,b,rBelow,gBelow,bBelow);
      
      % OLD METOHD
      %r = img(i,j,1) + 1;
      %g = img(i,j,2) + 1;
      %b = img(i,j,3) + 1;
      %membershipImg(i,j) = freqTable(r,g,b);
      
    end
  end
  
  % display the membership image
  figure(33), subplot(3,3,2), imshow(membershipImg), title('membership img');
  
  % create a bw image from the membership image. high threshold = fewer
  % components
  %level = 0.2
  level = graythresh(membershipImg);
  bwMmbshipImg = im2bw(membershipImg,level);
  if figuresOn
    figure(33), subplot(3,3,3), imshow(bwMmbshipImg), title('bw membership image');
  end
  
  % Delete small areas
  bwMmbshipImg = bwareaopen(bwMmbshipImg,round(100*scaleFactor),4);
  
  if figuresOn
    figure(33), subplot(3,3,4), imshow(bwMmbshipImg), title('cleand bw mbship image');
  end
  
  % dilate to enhance white areas in bw image. TO-DO!!
  %line = strel('line',20,10);
  line = strel('rectangle',[5,10]);
  bwMmbshipImg = imdilate(bwMmbshipImg,line);
  if figuresOn
    figure(33), subplot(3,3,5), imshow(bwMmbshipImg), title('dilated bw mbship image');
  end  

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Create connected components and get best candidate %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  % create connected components
  [conComp, noOfComp] = bwlabel(bwMmbshipImg);
 
  
  % display components
  if figuresOn
    figure(33), subplot(3,3,6), imshow(conComp), title('conComp');
  end
  
  % find coordinates of possible plate
  plateCoords = [0, 0, 0, 0];
  plateFound = false;
  plateCoords = GetBestCandidate(conComp,1);
  if plateCoords ~= [inf inf inf inf]
    plateFound = true;
  end
  
  % display found plate, if any
  if plateFound && figuresOn
    figure(33), subplot(3,3,7), imshow(img(plateCoords(3):plateCoords(4),plateCoords(1):plateCoords(2),:)), title('plate');
  end

end

