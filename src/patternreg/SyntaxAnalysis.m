% Make syntax analysis.
%
% Input:
% - charHitLists: a 7 x 31 matrix containing the hitlist of each of the
% seven chars.
% - distances: the distances for each char-vector to each meanVector.
% size(distances) == 7,31
%
% Output:
% - syntaxAnalysedStr: the plate as a string, syntax analysed
function [syntaxAnalysedStr, hits] = SyntaxAnalysis (charHitLists, distances, maxHitNo)

  %%%%%%%%%%%
  % LETTERS %
  %%%%%%%%%%%
  
  badLetterCombs = ['BH'; 'BU'; 'CC'; 'CD'; 'DK'; 'DU'; 'EU'; 'KZ'; ...
    'MU'; 'PU'; 'PY'; 'SS'; 'UD'; 'UN'; 'VC'];
  
  % function to find next letter char in hitlist
  function currentHit = GetNextLetterHit (hitList, currentHit)
    while currentHit < 31 && ~isempty(regexp(hitList(currentHit),'\d'))      
      currentHit = currentHit + 1;
    end
  end
  
  letter1Hitlist = charHitLists(1,:);
  letter2Hitlist = charHitLists(2,:);
  
  letter1CurrentHit = GetNextLetterHit(letter1Hitlist,1);
  letter2CurrentHit = GetNextLetterHit(letter2Hitlist,1);
  
  % search for bad letter combinations or 'O's in second spot
  currentComb = strcat(letter1Hitlist(letter1CurrentHit), ...
    letter2Hitlist(letter2CurrentHit));
  while ~isempty(strmatch(currentComb,badLetterCombs)) || ...
      strcmp(letter2Hitlist(letter2CurrentHit),'O')
    if strcmp(letter2Hitlist(letter2CurrentHit),'O') || distances(1,letter1CurrentHit) < distances(2,letter2CurrentHit)
      letter2CurrentHit = GetNextLetterHit(letter2Hitlist,letter2CurrentHit+1);
    else
      letter1CurrentHit = GetNextLetterHit(letter1Hitlist,letter1CurrentHit+1);
    end
    currentComb = strcat(letter1Hitlist(letter1CurrentHit), ...
      letter2Hitlist(letter2CurrentHit));
  end
  
  
  %%%%%%%%%%
  % DIGITS %
  %%%%%%%%%%
  
  % the value of the digits must be within the range 20000-75999
  maxValueD1D2 = 75;
  minValueD1D2 = 20;
  
  % function to find next digit char in hitlist
  function currentHit = GetNextDigitHit (hitList, currentHit)
    while currentHit < 31 && ~isempty(regexp(hitList(currentHit),'\D'))
      currentHit = currentHit + 1;
    end
  end
  
  digit1Hitlist = charHitLists(3,:);
  digit2Hitlist = charHitLists(4,:);
  digit3Hitlist = charHitLists(5,:);
  digit4Hitlist = charHitLists(6,:);
  digit5Hitlist = charHitLists(7,:);
  
  digit1CurrentHit = GetNextDigitHit(digit1Hitlist,1);
  digit2CurrentHit = GetNextDigitHit(digit2Hitlist,1);
  digit3CurrentHit = GetNextDigitHit(digit3Hitlist,1);
  digit4CurrentHit = GetNextDigitHit(digit4Hitlist,1);
  digit5CurrentHit = GetNextDigitHit(digit5Hitlist,1);
  
  % while the value of the first digit is to high/low: iterate
  %currentValueD1 = str2num(digit1Hitlist(digit1CurrentHit));
  %while currentValueD1 < minValueD1 || currentValueD1 > maxValueD1
  %  digit1CurrentHit = GetNextDigitHit(digit1Hitlist,digit1CurrentHit+1);
  %  currentValueD1 = str2num(digit1Hitlist(digit1CurrentHit));
  %end
  
  % while the value of the first two digits is to high/low: iterate
  currentValueD1D2 = str2num([digit1Hitlist(digit1CurrentHit) digit2Hitlist(digit2CurrentHit)]);
  while currentValueD1D2 < minValueD1D2 || currentValueD1D2 > maxValueD1D2
    if distances(1,digit1CurrentHit) < distances(2,digit2CurrentHit)
      digit2CurrentHit = GetNextDigitHit(digit2Hitlist,digit2CurrentHit+1);
    else
      digit1CurrentHit = GetNextDigitHit(digit1Hitlist,digit1CurrentHit+1);
    end
    if digit1CurrentHit > 31 || digit2CurrentHit > 31
      break;
    end
    currentValueD1D2 = str2num([digit1Hitlist(digit1CurrentHit) digit2Hitlist(digit2CurrentHit)]);
  end
  
  
  %%%%%%%%%%%%%%%%%
  % CREATE STRING %
  %%%%%%%%%%%%%%%%%
  
  % TO-DO: Could be done with matrix == less code?
  
  if letter1CurrentHit <= maxHitNo
    l1 = letter1Hitlist(letter1CurrentHit);
  else
    l1 = '_';
  end
  if letter2CurrentHit <= maxHitNo
    l2 = letter2Hitlist(letter2CurrentHit);
  else
    l2 = '_';
  end
  if digit1CurrentHit <= maxHitNo
    d1 = digit1Hitlist(digit1CurrentHit);
  else
    d1 = '_';
  end
  if digit2CurrentHit <= maxHitNo
    d2 = digit2Hitlist(digit2CurrentHit);
  else
    d2 = '_';
  end
  if digit3CurrentHit <= maxHitNo
    d3 = digit3Hitlist(digit3CurrentHit);
  else
    d3 = '_';
  end
  if digit4CurrentHit <= maxHitNo
    d4 = digit4Hitlist(digit4CurrentHit);
  else
    d4 = '_';
  end
  if digit5CurrentHit <= maxHitNo
    d5 = digit5Hitlist(digit5CurrentHit);
  else
    d5 = '_';
  end
  
  
  syntaxAnalysedStr = [l1 l2 d1 d2 d3 d4 d5];
  hits = [letter1CurrentHit letter2CurrentHit digit1CurrentHit ...
    digit2CurrentHit digit3CurrentHit digit4CurrentHit digit5CurrentHit];

end