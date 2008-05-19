% Given an image of a car with a licenseplate, rotate this image so the plate is
% placed horizontal in the image. The function only rotates the image if
% the rotation degree found during the analysis is >= minRotation. The
% maximum rotation is set to 10 as it shouldn't be necsseasry to rotate the
% images more than this (lav dette til en variable også??).
%
% Input parameters:
% - imgFile: file containing the image with a plate.
% - plateCoords: the coordinates of the plate in the image.
% - figuresOn: true/false whether figures should be printed.
%
% Output parameters:
% - rotatedImg: the image, rotated so the plate is horizontally placed.
% - plateCoords: the coordinates of the plate in the rotated image.
function [rotatedPlateImg, newPlateCoords] = plate_rotate_radon (imgFile, plateCoords, figuresOn)
  
  % specify the minimum rotation degree. Image will not be rotated if the
  % analysis indicates a rotation lower than this.
  minRotation = 1;

  % read image and make it grayscale
  img = imread(imgFile);
  %grayImg = rgb2gray(img);
  
  % pick out plate image and show it
  plateImg = img(plateCoords(3):plateCoords(4), plateCoords(1):plateCoords(2),:);
  grayPlateImg = rgb2gray(plateImg);
  if figuresOn
    figure(11), subplot(3,1,1), imshow(plateImg), title('input plate image');
    %imwrite(plateImg,'/Users/epb/Documents/datalogi/3aar/bachelor/pics/rotate_example_input.jpg','jpg');
  end
  
  % enhance contrast etc. TO-DO??
  
  % compute binary edge image from grayImg
  bwPlateImg = edge(grayPlateImg,'sobel','horizontal');
  %bwPlateImg = edge(grayPlateImg,'prewitt','horizontal');
  %bwPlateImg = edge(grayPlateImg,'roberts'); VERY BAD
  %bwPlateImg = edge(grayPlateImg,'log');
  %bwPlateImg = edge(grayPlateImg,'canny');
  if figuresOn
    figure(11), subplot(3,1,2), imshow(bwPlateImg), title('edge image, normal');
    %imwrite(bwPlateImg,'/Users/epb/Documents/datalogi/3aar/bachelor/pics/rotate_example_edge.jpg','jpg');
  end

  % compute radon transform of edge image
  %theta = [80:100];
  theta = 0:179;
  [radonMatrix,xp] = radon(bwPlateImg,theta);
  
  % display radon matrix
  if figuresOn
    %figure(111), imagesc(theta, xp, radonMatrix); colormap(hot);
    %xlabel('\theta'); ylabel('x\prime');
    %title('Radon transformation_{\theta} {x\prime}');
    %colorbar
  end

  % find degree of which the largest registration in Radon transformation
  % matrix was found
  [x,degree] = max(max(abs(radonMatrix)));
  %rotateDeg = 90 - (degree + 80 - 1) % plus 80 because of the 80:100 radonmatrix
  rotateDeg = 90 - (degree - 1)
  
  %if rotateDeg > 1 || rotateDeg < -1
  %  pause;
  %end

  % only rotate if rotateDeg is between minRotation and 10
  rotated = false;
  if abs(rotateDeg) >= minRotation % no need to check for <= 10 because of 80:100
    %rotatedImg = imrotate(img,rotateDeg,'bilinear','crop');
    rotatedPlateImg = imrotate(plateImg,rotateDeg,'bilinear','crop');
    rotated = true;
  else
    %rotatedImg = img;
    rotatedPlateImg = plateImg;
  end
  
  % set new platecoords using rotation matrix
  newPlateCoords = plateCoords;
  if rotated
    %imgMiddle = [size(img,1)/2, size(img,2)/2];
    plateImgMiddle = [(plateCoords(1)+plateCoords(2))/2, ...
      (plateCoords(3)+plateCoords(4))/2];
    %yDif = imgMiddle(1) - 1; % difference from original origo
    %xDif = imgMiddle(2) - 1;
    yDif = plateImgMiddle(1) - 1; % difference from plate origo
    xDif = plateImgMiddle(2) - 1;
    
    % the rotation matrix
    rotationMatrix = [cosd(rotateDeg) -sind(rotateDeg); ...
      sind(rotateDeg) cosd(rotateDeg)];
    
    % current coordinates
    minXY = [plateCoords(1)-xDif;plateCoords(3)-yDif];
    maxXY = [plateCoords(2)-xDif;plateCoords(4)-yDif];
    
    % find rotated coordinates
    minXY = rotationMatrix * minXY;
    maxXY = rotationMatrix * maxXY;
    
    % save rotated coordinates
    newPlateCoords(1) = round(minXY(1) + xDif);
    newPlateCoords(3) = round(minXY(2) + yDif);
    newPlateCoords(2) = round(maxXY(1) + xDif);
    newPlateCoords(4) = round(maxXY(2) + yDif);
  end
  
  % display rotated image
  if figuresOn
    %figure(11), subplot(3,1,3), imshow(rotatedImg(newPlateCoords(3):newPlateCoords(4), newPlateCoords(1):newPlateCoords(2), :)), title('rotated plate image');
    figure(11), subplot(3,1,3), imshow(rotatedPlateImg), title('rotated plate image');
    %imwrite(rotatedPlateImg,'/Users/epb/Documents/datalogi/3aar/bachelor/pics/rotate_example_output.jpg','jpg');
    %figure(66), imshow(img(newPlateCoords(3):newPlateCoords(4), newPlateCoords(1):newPlateCoords(2), :));
  end

end
