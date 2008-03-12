% Function to retrieve some coordinates from a filename. The filename must
% be on form [P][F][B]_xMin-xMax-yMin-yMax_XXXXXXX.jpg.
function [xMin, xMax, yMin, yMax] = getCoord (file)
  
  xMin = str2double(file(3:6));
  xMax = str2double(file(8:11));
  yMin = str2double(file(13:16));
  yMax = str2double(file(18:21));
  
return;