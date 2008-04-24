%%%%%%%%%%%%% function to create frequencytable using 
%%%%%%%%%%%%% all images in a folder
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [horizontalTable, verticalTable] = make_freq_table (imgFolder)

  fileList = dir([imgFolder '*.JPG']);
  noOfImages = length(fileList);

  ['Making frequency table for ' int2str(noOfImages) ' images.']
  
  % create table to hold frequencies: OLD METHOD
  %freqTable = zeros(256,256,256);

  % create table to hold normalized frequencies: OLD METHOD
  %normFreqTable = zeros(size(freqTable));
  
  %% NEW METHOD: 16 x 16 x ... tables
  horizontalTable = zeros(16,16,16,16,16,16);
  verticalTable = zeros(16,16,16,16,16,16);
  
  
  for i = 1:noOfImages
    % get coordinates of plate and read image
    plateCoords = [str2num(fileList(i).name(1,3:6)), ...
      str2num(fileList(i).name(1,8:11)), ...
      str2num(fileList(i).name(1,13:16)), ...
      str2num(fileList(i).name(1,18:21))];
    
    img = imread(strcat(imgFolder, fileList(i).name));
    plateImg = img(plateCoords(3):plateCoords(4),...
                plateCoords(1):plateCoords(2),:);
              
    figure(44), imshow(plateImg), title('plate image');
    
    % get dimensions of image
    imgHeight = size(plateImg,1);
    imgWidth = size(plateImg,2);

    % iterate through image and register frequencies: OLD METHOD
    %for y = 1:imgHeight
    %  for x = 1:imgWidth
    %    r = plateImg(y,x,1) + 1;
    %    g = plateImg(y,x,2) + 1;
    %    b = plateImg(y,x,3) + 1;
    %    freqTable(r,g,b) = freqTable(r,g,b) + 1;
    %  end
    %end
    
    % iterate through image and register frequencies: NEW METHOD
    for y = 1:imgHeight-1
      for x = 1:imgWidth-1
        
        r = floor(double(plateImg(y,x,1))/16)+1;
        g = floor(double(plateImg(y,x,2))/16)+1;
        b = floor(double(plateImg(y,x,3))/16)+1;
        
        rRight = floor(double(plateImg(y,x+1,1))/16)+1;
        gRight = floor(double(plateImg(y,x+1,2))/16)+1;
        bRight = floor(double(plateImg(y,x+1,3))/16)+1;
        
        rBelow = floor(double(plateImg(y+1,x,1))/16)+1;
        gBelow = floor(double(plateImg(y+1,x,2))/16)+1;
        bBelow = floor(double(plateImg(y+1,x,3))/16)+1;
        
        % sum up frequencies
        horizontalTable(r,g,b,rRight,gRight,bRight) = ...
          horizontalTable(r,g,b,rRight,gRight,bRight) + 1;
        verticalTable(r,g,b,rBelow,gBelow,bBelow) = ...
          verticalTable(r,g,b,rBelow,gBelow,bBelow) + 1;
        
      end
    end
    

    %%%%%%%%%%%%%%%%%% normalizing %%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % find frequency of most occuring color: OLD METHOD
    %maxFreq = max(max(max(freqTable)));

    % normalize using maxFreq: OLD METHOD
    %normFreqTable = freqTable/maxFreq;
    
    % normalize: NEW METHOD
    maxFreqHori = max(max(max(max(max(max(horizontalTable))))));
    maxFreqVert = max(max(max(max(max(max(verticalTable))))));
    
    horizontalTable = horizontalTable/maxFreqHori;
    verticalTable = verticalTable/maxFreqVert;

  end

end