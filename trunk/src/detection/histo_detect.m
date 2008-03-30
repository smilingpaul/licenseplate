% function to detect a plate in an image using the 'histrogram method'. The
% frequency table must be constructed before this function is run
function plateCoords = histo_detect(imgFile, freqTable)

  % read image from file and display it
  img = imread(imgFile);
  %img = imresize(img,0.1);
  figure(33), subplot(2,3,1), imshow(img);
  
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
  for i = 1:imgHeight
    for j = 1:imgWidth
      r = img(i,j,1) + 1;
      g = img(i,j,2) + 1;
      b = img(i,j,3) + 1;
      membershipImg(i,j) = freqTable(r,g,b);
    end
  end
  
  % display the membership image
  figure(33), subplot(2,3,2), imshow(membershipImg);
  
  % create a bw image from the membership image. TO-DO: determine threshold
  %level = graythresh(membershipImg);
  %bwMmbshipImg = im2bw(membershipImg,level);
  bwMmbshipImg = im2bw(membershipImg,0.2);
  figure(33), subplot(2,3,3), imshow(bwMmbshipImg), title('Membership image');
  
  % dilate to enhance white areas in bw image. TO-DO!!
  %line = strel('line',10,2);
  line = strel('rectangle',[12,8]);
  bwMmbshipImg = imdilate(bwMmbshipImg,line);
  figure(33), subplot(2,3,4), imshow(bwMmbshipImg), title('bw membership image');
  
  % create connected components
  [conComp, noOfComp] = bwlabel(bwMmbshipImg);
  
  % remove connected components that cannot be used as plate
  % compRemoved holds the connected components that have been removed
  compRemoved = zeros(noOfComp,1);
  
  for i = 1:noOfComp
    
    % calculate dimensions of component and find all pixels in component
    compSize = length(find(conComp == i));
    [y,x] = find(conComp == i);
    compWidth = max(x) - min(x);
    compHeight = max(y) - min(y);
    
    % if component hasn't got correct relations, it is not the plate.
    % TO-DO: Not working!!!
    if ~(compWidth/compHeight > 3 && compWidth/compHeight < 5.5)
    
      % register that component has been removed
      compRemoved(i) = true;
      
      % set color of pixels in component to black
      for j = 1:compSize
        conComp(y(j), x(j)) = 0;
      end
    end
    
  end
  
  % display remaining components
  figure(33), subplot(2,3,5), imshow(conComp), title('conComp cleaned');
  
  % find coordinates of possible plate
  plateCoords = [0, 0, 0, 0];
  plateFound = false;
  
  for i = 1:noOfComp
    
    % if the component hasn't been removed it's likely the plate
    if ~compRemoved(i)
      [y,x] = find(conComp == i);
      plateCoords = [min(x)-1, max(x)+1, min(y)-1, max(y)+1];
      plateFound = true;
    end
    
  end
  
  % adjust coordinates if they point outside the image
  if plateCoords(1) < 1
    plateCoords(1) = 1;
  end
  if plateCoords(2) > imgWidth
    plateCoords(2) = imgWidth;
  end
  if plateCoords(3) < 1
    plateCoords(3) = 1;
  end
  if plateCoords(4) > imgHeight
    plateCoords(4) = imgHeight;
  end
  
  % display cut-out plate, if any
  if plateFound
    figure(33), subplot(2,3,6), imshow(img(plateCoords(3):plateCoords(4),plateCoords(1):plateCoords(2),:)), title('plate');
  end

end

