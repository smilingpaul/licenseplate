function [charHitLists, andHitLists] = ReadPlateAND (chars, imSize)
  
  % get the andImgs
  andImgsFile = load('/Users/epb/Documents/datalogi/3aar/bachelor/licenseplate/src/patternreg/andImgs');
  name = ['andImgs', int2str(imSize)];
  andImgs = andImgsFile.(name);
  
  % create char hit lists
  charHitLists = repmat('',7,31);
  andHitLists = zeros(7,31);
  
  for i = 1:7
    % resize and display image
    charName = strcat('char',int2str(i));
    
    % read char
    [charHitLists(i,:), andHitLists(i,:)] = ...
      ReadCharAND(chars.(charName),andImgs,imSize);
  end

end