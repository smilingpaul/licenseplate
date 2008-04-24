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
function [rotatedImg, plateCoords] = plate_rotate_radon (imgFile, plateCoords, figuresOn)
  
  % specify the minimum rotation degree. Image will not be rotated if the
  % analysis indicates a rotation lower than this.
  minRotation = 1;

  % read image and make it grayscale
  img = imread(imgFile);
  grayImg = rgb2gray(img);
  
  % pick out plate image and show it
  plateImg = grayImg(plateCoords(3):plateCoords(4), plateCoords(1):plateCoords(2));
  if figuresOn
    figure(11), subplot(3,1,1), imshow(plateImg), title('input plate image');
  end
  
  % enhance contrast etc. TO-DO??
  
  % compute binary edge image from grayImg
  bwPlateImg = edge(plateImg,'sobel','horizontal');
  %bwPlateImg = edge(plateImg,'prewitt','horizontal');
  %bwPlateImg = edge(plateImg,'roberts'); VERY BAD
  %bwPlateImg = edge(plateImg,'log');
  %bwPlateImg = edge(plateImg,'canny');
  if figuresOn
    figure(11), subplot(3,1,2), imshow(bwPlateImg), title('edge image, normal');
  end

  % compute radon transform of edge image, TO-DO: Only in 80:100
  [radonMatrix,xp] = radon(bwPlateImg,80:100);
  
  % display radon matrix
  %theta = 0:179;
  figure(111), imagesc(80:100, xp, radonMatrix); colormap(hot);
  %xlabel('\theta'); ylabel('x\prime');
  title('Radon transformation_{\theta} {x\prime}');
  colorbar

  % find degree of which the largest registration in Radon transformation
  % matrix was found
  [x,degree] = max(max(abs(radonMatrix)));
  rotateDeg = 90 - (degree + 80 - 1) % plus 80 because of the 80:100 radonmatrix  

  % convert the degree of rotation to horizontal plane
  %rotateDeg = 90 - degree + 1 % plus 1: correction, WHY IS IT NEEDED??

  % only rotate if rotateDeg is between minRotation and 10
  if abs(rotateDeg) >= minRotation % no need to check for <= 10 because of 80:100
    rotatedImg = imrotate(img,rotateDeg,'bilinear','crop');
  else
    rotatedImg = img;
  end
  
  % display rotated image
  if figuresOn
    figure(11), subplot(3,1,3), imshow(rotatedImg(plateCoords(3):plateCoords(4), plateCoords(1):plateCoords(2), :)), title('rotated plate image');
  end

end
