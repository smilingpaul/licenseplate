% Read a plate using 7 images of seven chars
%
% Input:
% - chars: images of the chars as a struct, indexed by chars.char1,
% chars.char2 etc.
% 
% Output:
% - plate: the plate as a string. Empty if no good guess
%
function [L1Chars, L2Chars, N1Chars, N2Chars, N3Chars, N4Chars, N5Chars] = ReadPlateFV (chars, height, width)

  % load meanVectors
  meanVectorsFile = load('/Users/epb/Documents/datalogi/3aar/bachelor/licenseplate/src/patternreg/meanVectorsCanon');
  meanVectors = meanVectorsFile.meanVectorsCanon;
  
  %letterCombinations = ...
  %  ['AA';	'AB';	'AC'; 'AD';	'AE';	'AH';	'AJ';	'AK'; 'AL';	'AM'; 'AN'; 'AP'; 'AR'; 'AS'; 'AT';	'AU'; 'AV'; 'AX'; 'AY'; 'AZ' ...
  %  'BA'; 'BB'; 'BC'; 'BD'; 'BE'; 'BJ'; 'BK'; 'BL'; 'BM'; 'BN'; 'BP'; 'BR'; 'BS'; 'BT'; 'BV'; 'BX'; 'BY'; 'BZ']
  
  %plate = '';
  
  % LETTERS
  L1Chars = ReadCharFV(chars.char1,meanVectors,height,width);
  L2Chars = ReadCharFV(chars.char2,meanVectors,height,width);
  
  % NUMBERS
  N1Chars = ReadCharFV(chars.char3,meanVectors,height,width);
  N2Chars = ReadCharFV(chars.char4,meanVectors,height,width);
  N3Chars = ReadCharFV(chars.char5,meanVectors,height,width);
  N4Chars = ReadCharFV(chars.char6,meanVectors,height,width);
  N5Chars = ReadCharFV(chars.char7,meanVectors,height,width);

  %plate = [L1Chars(1) L2Chars(1) N1Chars(1) N2Chars(1) N3Chars(1) N4Chars(1) N5Chars(1)];
  

end % function