%%%%%%%%%%%%% function to add frequencies of an image to a frequencytable
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function normFreqTable = make_freq_table (imgFile, freqTable)

% get coordinates of plate and read image
[xMin, xMax, yMin, yMax] = getCoord(imgFile);
img = imread(imgFile);
subImg = img(yMin:yMax,xMin:xMax,:);
figure(1), imshow(subImg), title('plate image');

% check dimensions of frequency table
%rMax = max(max(img(:,:,1)))
%gmax = max(max(img(:,:,2)))
%bMax = max(max(img(:,:,3)))
%if 

% for testing
%subImg = imgFile

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

%freqTable

%%%%%%%%%%%%%%%%%% some normalizing %%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%freqTable(242,239,246)

% create table to hold normalized frequencies
normFreqTable = zeros(size(freqTable));

% find frequency of most occuring color
maxFreq = max(max(max(freqTable)));
%1 / maxFreq
%normFreqTable(5,4,2) = freqTable(5,4,2)/maxFreq;
%normFreqTable(5,4,2)

% normalize using maxFreq
for r = 1:size(freqTable,1)
  for g = 1:size(freqTable,2)
    for b = 1:size(freqTable,3)
      normFreqTable(r,g,b) = freqTable(r,g,b)/maxFreq;
    end
  end
end

    
% find rgb-coordinates of most frequent color
%[columnMaxes,firstIndexes] = max(freqTable(:,:,2))
%[maxFreq, secondIndex] = max(columnMaxes)
%firstIndex = firstIndexes(secondIndex)

%%%%%%% put values in normalized frequency table %%%%%%%

% create table to hold normalized values
%normFreqTable = zeros(size(freqTable));
%normFreqTable = freqTable;

end