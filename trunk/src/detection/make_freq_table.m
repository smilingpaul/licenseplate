%%%%%%%%%%%%% function to create frequencytable using 
%%%%%%%%%%%%% all images in a folder
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function normFreqTable = make_freq_table (imgFolder)

  fileList = dir([imgFolder '*.JPG']);
  noOfImages = length(fileList);

  ['Making frequency table for ' int2str(noOfImages) ' images.']

  % create table to hold frequencies
  freqTable = zeros(255,255,255);

  % create table to hold normalized frequencies
  normFreqTable = zeros(size(freqTable));

  for i =1:noOfImages
    % get coordinates of plate and read image
    %strcat(imgFolder, fileList(i).name)
    [xMin, xMax, yMin, yMax] = getCoord(fileList(i));

    %imgFile.name(1,3:6)
    %realPlateCoords = [str2num(imgFile.name(1,3:6)), str2num(imgFile.name(1,8:11)), ...
    %                            str2num(imgFile.name(1,13:16)), str2num(imgFile.name(1,18:21))];

    img = imread(strcat(imgFolder, fileList(i).name));
    subImg = img(yMin:yMax,xMin:xMax,:);
    %subImg = img(realPlateCoords(3):realPlateCoords(4),realPlateCoords(1):realPlateCoords(2),:);
    figure(44), imshow(subImg), title('plate image');

    % get dimensions of image
    imgHeight = size(subImg,1);
    imgWidth = size(subImg,2);

    % iterate through image
    for y = 1:imgHeight
      for x = 1:imgWidth
        r = subImg(y,x,1) + 1;
        g = subImg(y,x,2) + 1;
        b = subImg(y,x,3) + 1;
        freqTable(r,g,b) = freqTable(r,g,b) + 1;
      end
    end

    %%%%%%%%%%%%%%%%%% normalizing %%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % find frequency of most occuring color
    maxFreq = max(max(max(freqTable)));
    %1 / maxFreq
    %normFreqTable(5,4,2) = freqTable(5,4,2)/maxFreq;
    %normFreqTable(5,4,2)

    % normalize using maxFreq
    %for r = 1:size(freqTable,1)
    %  for g = 1:size(freqTable,2)
    %    for b = 1:size(freqTable,3)
    %      normFreqTable(r,g,b) = freqTable(r,g,b)/maxFreq;
    %    end
    %  end
    %end
    normFreqTable = freqTable/maxFreq;

    % wait for user to press a key
    %pause();

  end

end