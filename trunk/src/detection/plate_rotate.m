% Given an image of a licenseplate, rotate this image so the plate is
% placed horizontal in the image. Input image  must be two-dimensional.
function [rotatedImg] = plate_rotate (img)
  
  % get coordinates
  %[xMin, xMax, yMin, yMax] = getCoord(imgFile);
  
  % display input img
  figure(1);
  subplot(2,1,1);
  imshow(img);
  
  % compute binary edge image, TO-DO: determine kind of edge-function
  bwImg = edge(img,'sobel');
  %bw = edge(img,'prewitt');
  %bw = edge(img,'roberts');
  %bw = edge(img,'log');
  %bw = edge(img,'canny');
  %figure, imshow(bw);

  % compute radon transform of edge image
  [radonMatrix,xp] = radon(bwImg);
  
  % radon matrix: make ready for storing
  %F = mat2gray(radon_matrix);
  %size(F)
  %figure, imshow(F); colormap(hot);
  %figure, imshow(R); colormap(hot);
  %imwrite(imagesc(theta, xp, R),'P_Radon.jpg');

  % display radon matrix
  %theta = 0:179;
  %figure(200);
  %imagesc(theta, xp, radon_matrix); colormap(hot);
  %xlabel('\theta'); ylabel('x\prime');
  %title('Radon transformation_{\theta} {x\prime}');
  %colorbar

  % find degree of which the largest registration in Radon transformation matrix was found
  %[x,degree] = max(max(abs(R)))

  % find rotation degree
  degree = find_deg(radonMatrix);

  % TEST OF HOUGH: TO-DO
  %[H,T,rho] = hough(bw);
  %display hough matrix
  %figure, subplot(2,1,2);
  %imshow(imadjust(mat2gray(H)),'XData',T,'YData',rho,'InitialMagnification','fit');
  %axis on, axis normal, hold on;
  %colormap(hot);
  % find peaks
  %peaks = houghpeaks(H)

  % rotate image, using nearest neighbour TO-DO: can other interpolations be used?
  % using 'crop' to specify size of rotated image
  rotatedImg = imrotate(img,degree,'bilinear','crop');
  figure(1);
  subplot(2,1,2);
  imshow(rotatedImg);

return;

% function to find the degree
function [rotateDeg] = find_deg (radonMatrix,lines)

  % threshold for maximum value of degree
  maxDeg = 45;

  % sort radon_matrix so the 
  %radon_matrix = sort(radon_matrix,'descend');

  % find the clearest line(s) in the img
  %degrees = zeros(lines);
  %for n = 1:lines
    [x,degree] = max(max(abs(radonMatrix)));
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
  rotateDeg = 90 - degree;

  if (rotateDeg > maxDeg)
    rotateDeg = 0;
  end

  return;
