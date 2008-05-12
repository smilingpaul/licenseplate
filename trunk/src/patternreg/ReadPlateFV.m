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