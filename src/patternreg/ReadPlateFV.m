% Read a plate using 7 images of seven chars
%
% Input:
% - chars: images of the chars as a struct, indexed by chars.char1,
% chars.char2 etc.
% 
% Output:
% - charHitLists: 
function [charHitLists, euclidDists] = ReadPlateFV (chars, height, width)

  % load meanVectors
  meanVectorsFile = load('/Users/epb/Documents/datalogi/3aar/bachelor/licenseplate/src/patternreg/meanVectorsCanon');
  meanVectors = meanVectorsFile.meanVectorsCanon;
  
  % create char hit lists
  charHitLists = repmat('',7,31);
  euclidDists = zeros(7,31);
  for i = 1:7
    charName = strcat('char',int2str(i));
    [charHitLists(i,:), euclidDists(i,:)] = ...
      ReadCharFV(chars.(charName),meanVectors,height,width);
  end

end % function

function [charHitlist, euclidDistsHitList] = ReadCharFV (charImg, meanVectors, height, width)

  % order of meanvectors must be:
  % 0,1,2,3,4,5,6,7,8,9,A,B,C,D,E,H,J,K,L,M,N,O,P,R,S,T,U,V,X,Y,Z
  chars = '0123456789ABCDEHJKLMNOPRSTUVXYZ';

  % resize image and make vector. TO-DO: OTHER RESIZE METHOD?
  resizedImg = imresize(charImg, [height width]);
  imgVector = reshape(resizedImg,height*width,1);
  
  % calculate euclidian distances to all 31 meanvectors
  euclidDists = zeros(31,1);
  for i = 1:size(meanVectors,2)
    euclidDists(i) = sqrt(sum((imgVector-meanVectors(:,i)).^2));
  end
  euclidDistsHitList = zeros(size(euclidDists));
  
  % sort the chars by minimum euclidian distance: nearest first
  charHitlist = '';
  for i = 1:length(chars)
    [minDist, minIndex] = min(euclidDists);
    charHitlist = strcat(charHitlist,chars(minIndex));
    euclidDistsHitList(i) = minDist;
    euclidDists(minIndex) = inf;
  end

end