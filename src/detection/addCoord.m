% Function to add some coordinates to a filename. The current filename must
% be on form [P][F][B]_XXXXXXX.jpg, where 'XXXXXXX' is the characters of
% the plate. The user inputs two mouseclicks specifing the upper-left
% corner and the lower-right corner of the licenseplate. The new filename
% will be on the form [P][F][B]_xMin-xMax-yMin-yMax_XXXXXXX.jpg.
function [] = addCoord (file, xMin, xMax, yMin, yMax)
  
  % make new filename
  pathLength = length(file);
  fileNameStart = pathLength - 12
  
  % pad 0's
  %coords = [xMin, xMax, yMin, yMax];
  
  %for c = coords
  %  if c < 10
  %    coordinates = strcat(coordinates,'000',int2str(c),'-');
  %  elseif c < 100
  %    coordinates = strcat(coordinates,'00',int2str(c),'-');
  %  elseif c < 1000
  %    coordinates = strcat(coordinates,'0',int2str(c),'-');
  %  else
  %    coordinates = strcat(coordinates,int2str(c),'-');
  %  end
  %end
  
  coordinates = strcat(int2str(xMin),'-',int2str(xMax),'-',int2str(yMin),'-',int2str(yMax));
  newName = strcat(file(1:fileNameStart+1),coordinates,'_',file(fileNameStart+2:pathLength));
  
  % rename file
  movefile(file,newName);
  
return