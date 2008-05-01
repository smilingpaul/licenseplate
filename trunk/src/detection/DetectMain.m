function plateCoords = DetectMain(inputImage)


  % Read image from file
  origImage = rgb2gray(imread(inputImage));



  % High contrast blocks
  f1c = DetectSpread(inputImage);
  candCoords(1,1:4) = f1c;   

  % Finds candidates based on sameness
  f2c = DetectSameness(inputImage);
  candCoords(2,1:4) = f2c;   

  % Finds candidates based on avg filter 
  f3c = DetectContrastAvg(inputImage);
  candCoords(3,1:4) = f3c;  

  % Finds candidates based on freq analysis 
  f4c = DetectPlateness(inputImage);
  candCoords(4,1:4) = f4c;   


  % Calculate average candidate
  %avgCand = round([ mean(candCoords(:,1)) mean(candCoords(:,2)) ...
  %           mean(candCoords(:,3)) mean(candCoords(:,4)) ]);

  % Remove zero candidates [ 0 0 0 0 ]
  candCoords = reshape(nonzeros(candCoords),[],4);

  %%%%%%%%%%%%%%%%%%%%  
  % Select candidate %
  %%%%%%%%%%%%%%%%%%%%


  % Add columns to hold agreement level and candidates agreed with
  % for each cand we then have
  % [ minX, maxX, minY, maxY, agreement, cand1, cand2, cand3, cand4 ]
  candCoords(:,5:9) = 0;

candCoords 

  % How many candidates are we looking at?
  noOfCandidates = size(candCoords,1);



  % Loop through candidates and calc how
  % many components agree with each component
  % Too agree is to have center within component
  for i = 1:noOfCandidates % cand to mark
    for j = 1:noOfCandidates % looking at cand
      thisCenter =  [ sum(candCoords(j,1:2))/2, sum(candCoords(j,3:4))/2 ];
      %if i ~= j % Dont check myself
        % Is center of comp j within comp i?
        if thisCenter(1) > candCoords(i,1) && thisCenter(1) < candCoords(i,2) && ...
           thisCenter(2) > candCoords(i,3) && thisCenter(2) < candCoords(i,4)
          
           % Register agreement occurence
           candCoords(i,5) = candCoords(i,5) + 1; % Register agreement
           % Register who agreed with me (i)           
           candCoords(i,5+j) = j;

        end % if within 
      %end
    end % inner
  end % outher

  candCoords
 
  %%%%%%%%%%%%%%%%%%%%%%%%%
  % Decide on a candidate %
  %%%%%%%%%%%%%%%%%%%%%%%%%


  % Agreement level
  agLev = max(max(candCoords(:,5)));

  if noOfCandidates == 1
    % We have only one candidate
    plateCoords = candCoords(1,1:4);
  
  elseif agLev >= 2
    % Two or more candidates agree

    % What rows in the candCoords matrix have the maximum agree level
    agRows = find(candCoords(:,5) == agLev);
    
    % Get the list of candidates that agree
    % We just grab the 1st line (1st group).
    % In situations with two groups with two
    % candidates in each, we just grab the first (random)
    agCands = nonzeros(candCoords( agRows(1), 6:9));

    % Get the list of coords of the candidates we'll use
    goodCands = candCoords(agCands,1:4)

    plateCoords = [ min(goodCands(:,1)) max(goodCands(:,2)) ... 
                    min(goodCands(:,3)) max(goodCands(:,4)) ] 


  else
    % No agreement between candidates
    plateCoords = [ 0 0 0 0 ];
  end




%{
  % Are all candidate-centers whithin average candidate?
  % If yes,  they all agree and we return avg candidate
  
  allAgree = true;

  for i = 1:noOfCandidates
    myMeanX = mean(candCoords(i,1:2));
    myMeanY = mean(candCoords(i,3:4));
    if myMeanX < avgCand(1) || myMeanX > avgCand(2) || ...
       myMeanY < avgCand(3) || myMeanY > avgCand(4)
      allAgree = false;
  end  

  if allAgree == true
    % plateCoords = [];
    % return;
    [ 'We all agree here']
    plateCoords = avgCand;
  end
  
%}



  figure(300);
  imshow(origImage ./ 4);
  hold on;

  %line([10 100], [100 200]);

  if sum(plateCoords) > 0
    % Draw average candidate
    line( plateCoords(1:2), [plateCoords(3) plateCoords(3)] );
    line( plateCoords(1:2), [plateCoords(4) plateCoords(4)] );
    line( [plateCoords(1) plateCoords(1)], plateCoords(3:4) );
    line( [plateCoords(2) plateCoords(2)], plateCoords(3:4) );
  end

  plot(sum(f1c(1:2))/2, sum(f1c(3:4))/2,'ro');

  plot(sum(f2c(1:2))/2, sum(f2c(3:4))/2,'bo');

  plot(sum(f3c(1:2))/2, sum(f3c(3:4))/2,'go');

  plot(sum(f4c(1:2))/2, sum(f4c(3:4))/2,'gx');


  hold off;

%{
  figure(301);
  subplot(1,3,1);
  if sum(f1c) > 0
    sig = GetSignature(origImage(f1c(3):f1c(4),f1c(1):f1c(2)), 2);
    plot(sig);
    %title(['red ' int2str(pness)]);
  else
    plot(zeros(1));
  end
  title('red');
  

  subplot(1,3,2);
  if sum(f2c) > 0
    sig = GetSignature(origImage(f2c(3):f2c(4),f2c(1):f2c(2)), 2);
    plot(sig);
    %title(['blue ' int2str(pness)]);
  else
    plot(zeros(1));
  end
  title('blue');

  subplot(1,3,3);
  if sum(f3c) > 0
    sig = GetSignature(origImage(f3c(3):f3c(4),f3c(1):f3c(2)), 2);
    plot(sig);
    title(['green ' int2str(GetPlateness(sig))]);
  else
    plot(zeros(1));
    title('green');
  end
%}



  
end
