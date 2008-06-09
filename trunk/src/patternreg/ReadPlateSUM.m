function [charHitLists, sumsHitLists] = ReadPlateSUM (chars, imSize)

  figuresOn = false;
  
  % list of all available chars
  allChars = '0123456789ABCDEHJKLMNOPRSTUVXYZ';
  
  charHitLists = repmat('',7,31);
  sumsHitLists = zeros(7,31);
  
  % get the andImgs
  sumImgsFile = load('/Users/epb/Documents/datalogi/3aar/bachelor/licenseplate/src/patternreg/sumImgs');
  name = ['sumImgs', int2str(imSize)];
  sumImgs = sumImgsFile.(name);
  
  for i = 1:7
    % resize and display image
    charName = strcat('char',int2str(i));
    %{
    resizedChar = imresize(chars.(charName), [imSize imSize]);
    if figuresOn
      figure(72), subplot(1,2,1), imshow(resizedChar), title('resizedChar');
    end
    %}
    
    %{
    % compare to 'sumimgs'
    sums = zeros(size(sumImgs,3),1);
    for j = 1:size(sumImgs,3)
      [y x] = find(resizedChar);
      
      for k = 1:size(y,1)
          sums(j) = sums(j) + sumImgs(y(k),x(k),j);
      end
      
    end
    %}
    
    % sort the chars by sum: largest first      
    %{
    charHitList = '';
    for j = 1:length(allChars)
      [bestSum bestCharIndex] = max(sums);
      charHitList = strcat(charHitList,allChars(bestCharIndex));
      sumsHitList(i,j) = 1/bestSum;
      sums(bestCharIndex) = 0;
    end
    %}
    
    [charHitLists(i,:), sumsHitLists(i,:)] = ReadCharSUM(chars,(charName),sumImgs,imSize);
    
  end

end