% Given an image of a licenseplate, rotate this image so the plate is placed horizontal in the image.
% Input image  must be two-dimensional.
function [rotated_img] = plate_rotate (img)
  
  % compute binary edge image, TO-DO: determine kind of edge-function
  bw = edge(img,'sobel');
  %figure, imshow(bw);
  %bw = edge(img,'prewitt');
  %figure, imshow(bw);
  %bw = edge(img,'roberts');
  %figure, imshow(bw);
  %bw = edge(img,'log');
  %figure, imshow(bw);
  %bw = edge(img,'canny');
  %figure, imshow(bw);

  % compute radon transform of edge image
  [R,xp] = radon(bw);
  
  %size(R)
  %radon_matrix = (theta, xp, R);
  %figure, imshow(R); colormap(hot);
  %imwrite(imagesc(theta, xp, R),'P_Radon.jpg');

  % display radon matrix
  theta = 0:179;
  figure, imagesc(theta, xp, R); colormap(hot);
  xlabel('\theta (grader)'); ylabel('x\prime');
  title('R_{\theta} {x\prime}');
  colorbar

  % find degree of which the largest registration in Radon transformation matrix was found
  [x,degree] = max(max(abs(R)))

  % TEST OF HOUGH
  [H,T,rho] = hough(bw);

  %display hough matrix
  figure, subplot(2,1,2);
  imshow(imadjust(mat2gray(H)),'XData',T,'YData',rho,'InitialMagnification','fit');
  axis on, axis normal, hold on;
  colormap(hot);

  % find peaks
  peaks = houghpeaks(H);

  % rotate image, using nearest neighbour TO-DO: can other interpolations be used?
  rotated_img = imrotate(img,90-degree);
  figure, imshow(rotated_img);

return;
