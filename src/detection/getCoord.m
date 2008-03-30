% Function to retrieve some coordinates from a filename. The filename must
% be on form [P][F][B]_xMin-xMax-yMin-yMax_XXXXXXX.jpg.
function [xMin, xMax, yMin, yMax] = getCoord (file)
  
  %file.name
  % find beginning of filename (position of [P][F][B])
  pathLength = length(file);
  fileNameStart = pathLength - 32;
  
  % get coordinates
  xMin = str2double(file(fileNameStart+2:fileNameStart+5));
  xMax = str2double(file(fileNameStart+7:fileNameStart+10));
  yMin = str2double(file(fileNameStart+12:fileNameStart+15));
  yMax = str2double(file(fileNameStart+17:fileNameStart+20));
  %xMin = str2double(file.name(3:6));
  %xMax = str2double(file.name(8:11));
  %yMin = str2double(file.name(13:16));
  %yMax = str2double(file.name(18:21));
  
end