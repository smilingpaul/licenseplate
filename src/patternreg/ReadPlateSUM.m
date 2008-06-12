function [charHitLists, sumsHitLists] = ReadPlateSUM (chars, imSize)
  
  charHitLists = repmat('',7,31);
  sumsHitLists = zeros(7,31);
  
  % get the andImgs
  sumImgsFile = load('/Users/epb/Documents/datalogi/3aar/bachelor/licenseplate/src/patternreg/sumImgs');
  name = ['sumImgs', int2str(imSize)];
  sumImgs = sumImgsFile.(name);
  
  for i = 1:7
    % resize and display image
    charName = strcat('char',int2str(i));
    
    % read char
    [charHitLists(i,:), sumsHitLists(i,:)] = ReadCharSUM(chars,(charName),sumImgs,imSize);
    
  end

end