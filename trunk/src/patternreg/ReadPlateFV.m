% Read a plate using 7 images of seven chars
%
% Input:
% - chars: images of the chars as a struct, indexed by chars.char1,
% chars.char2 etc.
% 
% Output:
% - plate: the plate as a string. Empty if no good guess
%
function plate = ReadPlateFV (chars)

  % load meanVectors
  meanVectorsFile = load('/Users/epb/Documents/datalogi/3aar/bachelor/licenseplate/src/patternreg/meanVectorsCanon');
  meanVectors = meanVectorsFile.meanVectorsCanon;
  
  plate = '';

  % for each char: get char-string
  for i = 1:7
    charField = ['char' int2str(i)];
    size(chars.(charField))
    [char1, char2, char3] = ReadCharFV(chars.(charField),meanVectors,5,3)
  
    % syntax analysis
    
    % letter
    if i < 3
      
    
    % number
    else
      
      
    end
    
    chosenChar = char1;
    
    
    % break if char is no good
    if 0
      plate = '';
      break;
    end
  
    % concat with rest of plate
    plate = strcat(plate,chosenChar);
    
  end

end % function