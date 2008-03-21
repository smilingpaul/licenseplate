% Function to rename all files, containing an image with a licenseplate,
% in a folder, so the new filename contains the coordinates of where the
% licenseplate is located in the image. The current filenames must be on
% form [P][F][B]_XXXXXXX.jpg, where 'XXXXXXX' is the characters of the plate.
% The user inputs two mouseclicks specifing the upper-left corner and the
% lower-right corner of each licenseplate. The new filenames will be on the
% form [P][F][B]_xMin-xMax-yMin-yMax_XXXXXXX.jpg. Note that (x,y) = (0,0) is
% upper-left corner of the image!
function [] = locate_plate (imgFolder)
  
  % Get filelist
  %fileList = dir([imgFolder '*.JPG']);
  fileList = dir([imgFolder 'F_YK32567.JPG']);
  noOfFiles = length(fileList);
  
  if noOfFiles < 1 
    'No files found. Aborting.'
    return;
  end
  
  % iterate through files
  for i = 1:noOfFiles
  
    % read image from file
    img = imread([imgFolder fileList(i).name]);

    % display image
    figure(100), imshow(img);

    % get mouse input
    [x,y] = ginput(2);

    % make new filename
    %pathLength = length(imgFile);
    %fileNameStart = pathLength - 12;
    %coordinates = strcat(int2str(x(1)),'-',int2str(x(2)),'-',int2str(y(1)),'-',int2str(y(2)));
    %newName = strcat(imgFile(1:fileNameStart+1),coordinates,'_',imgFile(fileNameStart+2:pathLength));

    % rename file
    %movefile(imgFile,newName);

    % rename file
    addCoord([imgFolder fileList(i).name],x(1),x(2),y(1),y(2));
    
  end
  
  % close figure with image
  close(100);

return;