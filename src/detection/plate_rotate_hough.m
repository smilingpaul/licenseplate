% Given an image of a licenseplate, rotate this image so the plate is
% placed horizontal in the image. Input image  must be two-dimensional.
function [rotatedPlateImg] = plate_rotate_hough (imgFile, xMin, xMax, yMin, yMax, figuresOn)
  
  % read image
  img = imread(imgFile);
  grayImg = rgb2gray(img);
  
  % display input img
  if figuresOn
    figure(1), subplot(2,2,1), imshow(grayImg), title('greyed input image');
  end
  
  % pick out plate image and show it
  plateImg = grayImg(yMin:yMax, xMin:xMax);
  if figuresOn
    figure(1), subplot(2,2,2), imshow(plateImg), title('plate image');
  end
  
  % compute binary edge image, TO-DO: determine kind of edge-function
  bwPlateImg = edge(plateImg,'sobel','horizontal');
  %bwPlateImg = edge(plateImg,'prewitt','horizontal');
  %bwPlateImg = edge(plateImg,'roberts'); VERY BAD
  %bwPlateImg = edge(plateImg,'log');
  %bwPlateImg = edge(plateImg,'canny');
  if figuresOn
    figure(1), subplot(2,2,3), imshow(bwPlateImg), title('edge image');
  end

  % TEST OF HOUGH: TO-DO
  [H,T,rho] = hough(bwPlateImg);
  %display hough matrix
  figure(74), subplot(2,1,2), imshow(imadjust(mat2gray(H)),'XData',T, ...
    'YData',rho,'InitialMagnification','fit');
  axis on, axis normal, hold on;
  colormap(hot);
  % find peaks
  peaks = houghpeaks(H)

  % rotate image, using 'crop' to specify size of rotated image
  %rotationMade = false;

  % find degree of which the largest registration in Radon transformation
  % matrix was found
  %[x,degree] = max(max(abs(radonMatrix)));
  degree = 10;
  degree = degree + 80; % plus 80 because of the 80:100 radonmatrix

  % convert the degree of rotation
  rotateDeg = 90 - degree

  % only rotate if rotateDeg is between 3 and 10
  %if abs(rotateDeg) > 10 || abs(rotateDeg) < 3
  if abs(rotateDeg) < 3 % no need to check for > 10 because of 80:100
    rotateDeg = 0;
  end

  
  
  if rotateDeg ~= 0
    rotatedImg = imrotate(img,rotateDeg,'bilinear','crop');
    %if figuresOn
    %  figure(1), subplot(3,2,4), imshow(rotatedImg), title('rotated image');
    %end
    %rotationMade = true;
    rotatedPlateImg = rotatedImg(yMin:yMax, xMin:xMax, :);
  else
    rotatedPlateImg = img(yMin:yMax, xMin:xMax, :);
  end
  
  % display rotated image
  if figuresOn
    figure(1), subplot(2,2,4), imshow(rotatedPlateImg), title('rotated plate image');
  end

end
