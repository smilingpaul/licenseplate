% Function to rename all files, containing an image with a licenseplate,
% in a folder, so the new filename contains the coordinates of where the
% licenseplate is located in the image. The current filenames must be on
% form [P][F][B]_XXXXXXX.jpg, where 'XXXXXXX' is the characters of the plate.
% The user inputs two mouseclicks specifing the upper-left corner and the
% lower-right corner of each licenseplate. The new filenames will be on the
% form [P][F][B]_xMin-xMax-yMin-yMax_XXXXXXX.jpg. Note that (x,y) = (0,0) is
% upper-left corner of the image!
function [] = LocatePlate (imgFolder)
  
  % Get filelist
  fileList = dir([imgFolder '*.JPG']);
  noOfFiles = length(fileList);
  
  if noOfFiles < 1 
    'No files found. Aborting.'
    return;
  end
  
  % iterate through files
  for i = 1:noOfFiles
  
    % get file name and read image from file
    fileName = fileList(i).name;
    img = imread([imgFolder fileName]);

    % display image
    figure(100), imshow(img);

    % get mouse input
    [x,y] = ginput(2);
    
    % rename file
    newFileName = GetNewFileName(fileName, x(1), x(2), y(1), y(2))
    movefile([imgFolder fileName],[imgFolder newFileName]);
  end
  
  close(100);  

return

function newFileName = GetNewFileName (fileName, xMin, xMax, yMin, yMax)
  
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
  
  
  % create new filename
  newFileName = strcat(fileName(1:2),coordStr,'_',fileName(3:13));
  
return