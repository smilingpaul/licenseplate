% Given an image of a car with a licenseplate, rotate this image so the plate is
% placed horizontal in the image. The function only rotates the image if
% the rotation degree found during the analysis is >= minRotation. The
% maximum rotation is set to 10 as it shouldn't be necsseasry to rotate the
% images more than this.
%
% Input parameters:
% - imgFile: file containing the image with a plate.
% - plateCoords: the coordinates of the plate in the image.
% - figuresOn: true/false whether figures should be printed.
%
% Output parameters:
% - rotatedImg: the image, rotated so the plate is horizontally placed.
% - plateCoords: the coordinates of the plate in the rotated image.
function [rotatedPlateImg, newPlateCoords] = RotatePlateRadon (imgFile, plateCoords, figuresOn)
  
  % specify the minimum rotation degree. Image will not be rotated if the
  % analysis indicates a rotation lower than this.
  minRotation = 1;

  % read image and make it grayscale
  img = imread(imgFile);
  
  % pick out plate image and show it
  plateImg = img(plateCoords(3):plateCoords(4), plateCoords(1):plateCoords(2),:);
  grayPlateImg = rgb2gray(plateImg);
  if figuresOn
    figure(11), subplot(3,1,1), imshow(plateImg), title('input plate image');
  end
  
  
  % compute binary edge image from grayImg
  bwPlateImg = edge(grayPlateImg,'sobel','horizontal');
  if figuresOn
    figure(11), subplot(3,1,2), imshow(bwPlateImg), title('edge image, normal');
  end

  % compute radon transform of edge image
  theta = 0:179;
  [radonMatrix,xp] = radon(bwPlateImg,theta);
  
  
  % display radon matrix
  if figuresOn
    figure(111), imagesc(theta, xp, radonMatrix); colormap(hot);
    colorbar
  end

  % find degree of which the largest registration in Radon transformation
  % matrix was found
  [x,degree] = max(max(abs(radonMatrix)));
  rotateDeg = 90 - (degree - 1)

  % only rotate if rotateDeg is between minRotation and 10
  rotated = false;
  if abs(rotateDeg) >= minRotation
    rotatedPlateImg = imrotate(plateImg,rotateDeg,'bilinear','crop');
    rotated = true;
  else
    rotatedPlateImg = plateImg;
  end
  
  % set new platecoords using rotation matrix
  newPlateCoords = plateCoords;
  if rotated
    plateImgMiddle = [(plateCoords(1)+plateCoords(2))/2, ...
      (plateCoords(3)+plateCoords(4))/2];
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
    figure(11), subplot(3,1,3), imshow(rotatedPlateImg), title('rotated plate image');
  end

end
