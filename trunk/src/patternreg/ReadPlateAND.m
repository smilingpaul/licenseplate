function [charHitLists, andHitLists] = ReadPlateAND (chars, imSize)

  %figuresOn = true;
  
  % list of all available chars
  %allChars = '0123456789ABCDEHJKLMNOPRSTUVXYZ';
  
  % the string to be returned
  %plateString = '_______';
  
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
    
    [charHitLists(i,:), andHitLists(i,:)] = ...
      ReadCharAND(chars.(charName),andImgs,imSize);
    
    %{
    resizedChar = imresize(chars.(charName), [imSize imSize]);
    if figuresOn
      figure(72), subplot(1,2,1), imshow(resizedChar), title('resizedChar');
    end
    
    % compare to 'andimgs'
    noOfAnds = zeros(size(allChars,1),1);
    for j = 1:size(andImgs,3)
      bla = resizedChar & andImgs(:,:,j);
      noOfAnds(j) = length(find(bla))
      if figuresOn
        figure(72), subplot(1,2,2), imshow(andImgs(:,:,j)), title('andImg');
      end
      pause;
    end
    
    % find char with max no. of ands. if one is a lone max: return it
    [maxAnds, maxChar] = max(noOfAnds);
    if length(find(noOfAnds == maxAnds)) == 1
      plateString(i) = allChars(maxChar);      
    end
    %}
  end

end