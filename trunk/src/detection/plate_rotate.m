% Given an image of a licenseplate, rotate this image so the plate is placed horizontal in the image.
% Input image  must be two-dimensional.
function [rotated_img] = plate_rotate (img)
  
  % compute binary edge image
  bw = edge(img);
  imshow(bw)

  % compute radon transform of edge image
  theta = 0:179;
  [R,xp] = radon(bw,theta);
  figure, imagesc(theta, xp, R); colormap(hot); colorbar

  % find degree of which the largest registration was found
  [x,degree] = max(max(abs(R)))
  

  % TO-DO: FIND RADIAL BASIS LINE NO.
  %max(R,[],2)

  % find radial line
  % [x,radial_line] = max(abs(R(:,degree)))

  %xp(1)

  %[S,xs] = radon(bw,degree);
  %figure, imshow(S); colormap(hot); colorbar
  
  %radial_line = R(degree,,38)

  % TO-DO: ROTATE IMAGE
  %rotated_img = rotate(bw,degree);

  %imshow(rotated_img);

return;
