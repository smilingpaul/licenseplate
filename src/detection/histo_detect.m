% function to detect a plate in an image using the 'histrogram method'
function plateCoords = histo_detect(img, freqTable)

  % display image
  figure(1), subplot(2,3,1), imshow(img);
  
  %img = rgb2gray(img);
  
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
  
  % create box to search for frequencies
  %searchBox = zeros(8,8);
  
  membershipImg = zeros(imgHeight,imgWidth);
  
  % iterate with box (8,8)
  for i = 1:imgHeight
    for j = 1:imgWidth
      r = img(i,j,1) + 1;
      g = img(i,j,2) + 1;
      b = img(i,j,3) + 1;
      membershipImg(i,j) = freqTable(r,g,b);
    end
  end
  
  %membershipImg
  
  figure(1), subplot(2,3,2), imshow(membershipImg);
    
  bla = im2bw(membershipImg);
  figure(1), subplot(2,3,3), imshow(bla);
  
  % dilate to enhance white areas
  %line = strel('line',10,2);
  line = strel('rectangle',[12,8]);
  bla = imdilate(bla,line);
  figure(1), subplot(2,3,4), imshow(bla);
  
  
  
  % create connected components
  [conComp, noOfComp] = bwlabel(bla);
  
  compRemoved = zeros(noOfComp,1);
  
  % remove connected components that cannot be used as plate
  for i = 1:noOfComp
    
    % calculate length of component and all pixels in component
    compSize = length(find(conComp == i));
    [y,x] = find(conComp == i);
    compWidth = max(x) - min(x);
    compHeight = max(y) - min(y);
    
    % if component hasn't got correct relations
    if ~(compWidth/compHeight > 3.5 && compWidth/compHeight < 5)
    

      % register that component has been removed
      compRemoved(i) = true;
      
      % set color of pixels in component to black
      for j = 1:compSize
        conComp(y(j), x(j)) = 0;
      end
      
    end
    
  end
  
  figure(1), subplot(2,3,5), imshow(conComp), title('conComp cleaned');
  
  for i = 1:noOfComp
    
    % if the component hasn't been removed it's likely the plate
    if ~compRemoved(i)
      [y,x] = find(conComp == i);
      plateCoords = [min(x)-1, max(x)+1, min(y)-1, max(y)+1]
    end
    
  end
  
  % display cut-out plate
  figure(1), subplot(2,3,6), imshow(img(plateCoords(3):plateCoords(4),plateCoords(1):plateCoords(2))), title('plate');

end

