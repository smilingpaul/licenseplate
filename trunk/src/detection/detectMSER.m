% detect licenseplate in a image using MSER
function [bucketList, sortVector] = detectMSER (imgFile)

% read and display image
img = imread(imgFile);
grayImg = rgb2gray(img);
%grayImg = im2double(rgb2gray(img));
figure(88), subplot(2,2,1), imshow(grayImg), title('input image (gray)');

%%% sort pixels by increasing intensity: bucket sort %%%

imgHeight = size(grayImg,1)
imgWidth = size(grayImg,2)
%noOfBuckets = size(grayImg,1)*size(grayImg,2);
noOfBuckets = 256

% create list of buckets: each bucket has a variable specifying the next
% free position in the bucket and a matrix specifying the bucket

defaultBucketSize = 4
%bucketList = zeros(noOfBuckets,4,5);
%bucketList(noOfBuckets) = struct('intensity',0,'x',0,'y',0);
bucketList(noOfBuckets) = struct('nextFreePos',1,'bucket',zeros(defaultBucketSize,2));

% split in buckets
%intensity = 0.999999;
%intensity = 1;
%bucketNo = floor(noOfBuckets*intensity)
%for x = 1:imgWidth
%  for y = 1:imgHeight
%    intensity = grayImg(y,x);
%    bucketNo = floor(noOfBuckets*intensity) + 1;
%    if bucketNo > noOfBuckets
%      bucketNo = noOfBuckets;
%    end
%      
%    % find the next free position
%    if isempty(bucketList(bucketNo).nextFreePos)
%      bucketList(bucketNo).nextFreePos = 1;
%    end
%    nextFreePos = bucketList(bucketNo).nextFreePos;
%    
%    bucketList(bucketNo).bucket(nextFreePos,1) = intensity;
%    bucketList(bucketNo).bucket(nextFreePos,2) = x;
%    bucketList(bucketNo).bucket(nextFreePos,3) = y;
%    bucketList(bucketNo).nextFreePos = nextFreePos + 1;
%  end
%end

% split up into buckets
for x = 1:imgWidth
  for y = 1:imgHeight
    
    % the bucket no. equals the intensity: pixels in bucket no. 4 has
    % intensity = 4
    bucketNo = double(grayImg(y,x)) + 1;
    
    % find the next free position
    
    % nextFreePos is only initialized in position no. "noOfBuckets", that
    % is the last bucket. If its not initialized it will be here.
    if isempty(bucketList(bucketNo).nextFreePos)
      bucketList(bucketNo).nextFreePos = 1;
    end
    nextFreePos = bucketList(bucketNo).nextFreePos;
    
    % insert coordinates
    bucketList(bucketNo).bucket(nextFreePos,1) = x;
    bucketList(bucketNo).bucket(nextFreePos,2) = y;
    
    bucketList(bucketNo).nextFreePos = nextFreePos + 1;
    
  end
end

% sort buckets, using insertion sort. NOT NECESSARY


% make sort vector: two columns with first and second coordinate
noOfPixels = size(img,1)*size(img,2)
%sortVector = zeros(noOfPixels,4); % column no. 3 is intensity. 4 is regionno.
sortVector = zeros(noOfPixels,3); % column no. 3 is intensity.

% concatenate sorted buckets
pos = 1;
for i = 1:noOfBuckets-1
  bucket = bucketList(i).bucket;
  bucketLength = size(bucket,1);
  
  % put bucket in sorted vector along with bucket no. (intensity)
  sortVector(pos:(pos+bucketLength)-1,1:2) = bucket;
  sortVector(pos:(pos+bucketLength)-1,3) = i-1;
  pos = pos + bucketLength;
end


%%%%% enumerate regions %%%%%

% regions are initialized with space for a region for every pixel and 100
% spaces of connected pixels, indexed by the index for a given pixel in
% sortVector. The first column is the intensity of the region. The second
% column in every row is the index of the next free element in the region
% (initialized to 3).
regions = zeros(noOfPixels,100); 
regions(:,2) = 3;
%regionNo = 1;

for i = 1:noOfPixels
  
  x = sortVector(i,1);
  y = sortVector(i,2);
  
  %sortVector(i,4) = regionNo;
  
  % iterate through previously made regions plus the one that will be made
  % (region i)
  for r = 1:i
    nextFreeRegIndex = regions(r,2);
   
    % if the region already contains pixels
    if nextFreeRegIndex > 3
      
      % iterate through pixels in region and see if the current pixel fits
      % in this region
      for p = 3:nextFreeRegIndex-1
        
      end
      
    else
      % store intensity
      regions(r,1) = sortVector(i,3);
      
      % add pixel to region
      regions(r,nextFreeRegIndex) = i;
      
      % increment index next free position
      regions(i,2) = nextFreeRegIndex + 1;
    end
    
  end
  
  %regionNo = regionNo + 1;
  
end



end