% Function to rename a file containing an image with a licenseplate, so
% the new filename contains the coordinates of where the licenseplate is
% located in the image. The current filename must be on form
% [P][F][B]_XXXXXXX.jpg, where 'XXXXXXX' is the characters of the plate.
% The user inputs two mouseclicks specifing the upper-left corner and the
% lower-right corner of the licenseplate. The new filename will be on the
% form [P][F][B]_xMin-xMax-yMin-yMax_XXXXXXX.jpg.
function [] = locate_plate (imgFile)
  
  % read image from file
  img = imread(imgFile);
  
  % display image
  figure(1);
  imshow(img);
  
  % get mouse input and close figure with image
  [x,y] = ginput(2);
  %close(1);
  
  % make new filename
  %pathLength = length(imgFile);
  %fileNameStart = pathLength - 12;
  %coordinates = strcat(int2str(x(1)),'-',int2str(x(2)),'-',int2str(y(1)),'-',int2str(y(2)));
  %newName = strcat(imgFile(1:fileNameStart+1),coordinates,'_',imgFile(fileNameStart+2:pathLength));
  
  % rename file
  %movefile(imgFile,newName);
  
  % rename file
  addCoord(imgFile,x(1),x(2),y(1),y(2));

return;