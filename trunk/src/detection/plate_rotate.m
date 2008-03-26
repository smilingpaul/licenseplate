% Given an image of a licenseplate, rotate this image so the plate is
% placed horizontal in the image. Input image  must be two-dimensional.
function [rotatedPlateImg] = plate_rotate (imgFile, xMin, xMax, yMin, yMax)
  
  % read image
  img = imread(imgFile);
  grayImg = rgb2gray(img);
  
  % display input img
  figure(1), subplot(3,2,1), imshow(grayImg);
  
  % pick out plate image and show it
  plateImg = grayImg(yMin:yMax, xMin:xMax);
  figure(1), subplot(3,2,2), imshow(plateImg);
  
  % compute binary edge image, TO-DO: determine kind of edge-function
  bwPlateImg = edge(plateImg,'sobel');
  %bwPlateImg = edge(plateImg,'prewitt');
  %bwPlateImg = edge(plateImg,'roberts');
  %bwPlateImg = edge(plateImg,'log');
  %bwPlateImg = edge(plateImg,'canny');
  figure(1), subplot(3,2,3), imshow(bwPlateImg);

  % compute radon transform of edge image, TO-DO: Only in 80:100
  [radonMatrix,xp] = radon(bwPlateImg,80:100);
  
  % display radon matrix
  %theta = 0:179;
  %figure(200);
  %imagesc(80:100, xp, radonMatrix); colormap(hot);
  %xlabel('\theta'); ylabel('x\prime');
  %title('Radon transformation_{\theta} {x\prime}');
  %colorbar

  % find degree of which the largest registration in Radon transformation matrix was found
  [x,degree] = max(max(abs(radonMatrix)));
  degree = degree + 80;

  % convert the degree of rotation
  rotateDeg = 90 - degree

  if abs(rotateDeg) > 10 || abs(rotateDeg) < 2
    rotateDeg = 0;
  end

  % TEST OF HOUGH: TO-DO
  %[H,T,rho] = hough(bw);
  %display hough matrix
  %figure, subplot(2,1,2);
  %imshow(imadjust(mat2gray(H)),'XData',T,'YData',rho,'InitialMagnification','fit');
  %axis on, axis normal, hold on;
  %colormap(hot);
  % find peaks
  %peaks = houghpeaks(H)

  % rotate image, using 'crop' to specify size of rotated image
  rotationMade = false;
  
  if rotateDeg ~= 0
    rotatedImg = imrotate(img,rotateDeg,'bilinear','crop');
    figure(1), subplot(3,2,4), imshow(rotatedImg);
    rotationMade = true;
  end
  
  % specify rotatedPlateImg and display it
  if rotationMade
    rotatedPlateImg = rotatedImg(yMin:yMax, xMin:xMax, :);
  else
    rotatedPlateImg = img(yMin:yMax, xMin:xMax, :);
  end
  figure(1), subplot(3,2,5), imshow(rotatedPlateImg);

end

% function to find the degree
%function [rotateDeg] = find_deg (radonMatrix,lines)

  % threshold for maximum value of degree
 % maxDeg = 45;

  % sort radon_matrix so the 
  %radon_matrix = sort(radon_matrix,'descend');

  % find the clearest line(s) in the img
  %degrees = zeros(lines);
  %for n = 1:lines
  %  [x,degree] = max(max(abs(radonMatrix)));
  %end

  %radon_matrix(:,88)
  %radon_matrix(:,89)
  %radon_matrix(1,40)
  %radon_matrix(1,41)
  %radon_matrix(1,42)
  %radon_matrix(1,43)
  %radon_matrix(1,44)
  %radon_matrix(1,45)
  %radon_matrix(1,46)

  % convert the degree of rotation
 % rotateDeg = 90 - degree;

  %if (rotateDeg > maxDeg)
   % rotateDeg = 0;
  %end

  %return;
