% Function to add coordinates to a filename. The current filename must
% be on form [P][F][B]_XXXXXXX.jpg, where 'XXXXXXX' is the characters of
% the plate. The new filename will be on the form
% [P][F][B]_xMin-xMax-yMin-yMax_XXXXXXX.jpg.
function [] = addCoord (file, xMin, xMax, yMin, yMax)
  
  % find beginning of filename (position of [P][F][B])
  pathLength = length(file);
  fileNameStart = pathLength - 12;
  
  % pad 0's in front of every coordinate
  coords = [xMin, xMax, yMin, yMax];
  coordStr = '';
  
  for c = 1:4
    if coords(c) < 10
      coordStr = strcat(coordStr,'000',int2str(coords(c)));
    elseif coords(c) < 100
      coordStr = strcat(coordStr,'00',int2str(coords(c)));
    elseif coords(c) < 1000
      coordStr = strcat(coordStr,'0',int2str(coords(c)));
    else
      coordStr = strcat(coordStr,int2str(coords(c)));
    end
    % if the coordinate is not the last, add a '-' afterwards
    if c ~= 4
      coordStr = strcat(coordStr,'-');
    end
  end
  
  %coordinates = strcat(int2str(xMin),'-',int2str(xMax),'-',int2str(yMin),'-',int2str(yMax));
  
  % create new filename and rename the file
  newName = strcat(file(1:fileNameStart+1),coordStr,'_',file(fileNameStart+2:pathLength));
  movefile(file,newName);
  
return