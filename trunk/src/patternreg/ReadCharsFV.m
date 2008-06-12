% Function that reads all images in a folder of folders with images of
% chars (using mean vectors)
function [percentagesAllChars, percentageDigits, percentageLetters] = ReadCharsFV (charFolder, vectorLength)

  % folders must be:
  % 0,1,2,3,4,5,6,7,8,9,A,B,C,D,E,H,J,K,L,M,N,O,P,R,S,T,U,V,X,Y,Z
  folderList = dir(charFolder);
  noOfFolders = length(folderList);
  percentagesAllChars = zeros(1,31);
  noOfDigits = 0;
  noOfLetters = 0;
  noOfDigitsRead = 0;
  noOfLettersRead = 0;
  
  % load meanVectors
  meanVectorsFile = load('meanVectors');
  %meanVectorsFile = load('sumImgs');
  %meanVectorsFile = load('andImgs');
  vectorName = ['meanVectors', int2str(vectorLength)];
  %vectorName = ['sumImgs', int2str(vectorLength)];
  %vectorName = ['andImgs', int2str(vectorLength)];
  meanVectors = meanVectorsFile.(vectorName);
  
  charNo = 1;
  
  for i = 1:noOfFolders
    
    % loop through each folder that holds char images
    folderName = folderList(i).name;
    if ~isempty(regexp(folderName,'[A-Z0-9]')) && folderList(i).isdir
      ['Reading ' folderName 's']
      
      noOfImgsRead = 0;
      imgFolder = [charFolder folderList(i).name '/'];
      imgList = dir(imgFolder);
      noOfElems = length(imgList);
      noOfImgs = 0;
      
      % read char images in folder and register how many have been read
      for j = 1:noOfElems
        if folderName == imgList(j).name(1)
          noOfImgs = noOfImgs + 1;
          
          % increment noOfDigits or Letters
          if ~isempty(regexp(folderName,'[0-9]'))
            noOfDigits = noOfDigits + 1;
          else
            noOfLetters = noOfLetters + 1;
          end
          
          charImg = imread([charFolder folderName '/' imgList(j).name]);
          [charHitList, euclidDist] = ReadCharFV(charImg,meanVectors,vectorLength);
          %[charHitList, euclidDist] = ReadCharSUM(charImg,meanVectors,vectorLength);
          %[charHitList, euclidDist] = ReadCharAND(charImg,meanVectors,vectorLength);
          if folderName == charHitList(1)
            noOfImgsRead = noOfImgsRead + 1;
            
            % increment noOfDigitsRead or LettersRead
            if ~isempty(regexp(folderName,'[0-9]'))
              noOfDigitsRead = noOfDigitsRead + 1;
            else
              noOfLettersRead = noOfLettersRead + 1;
            end
          end
        end
      end

      percentagesAllChars(charNo) = 100*(noOfImgsRead/noOfImgs);
      charNo = charNo + 1;
    end
  end
  
  percentageDigits = 100*(noOfDigitsRead/noOfDigits);
  percentageLetters = 100*(noOfLettersRead/noOfLetters);

end