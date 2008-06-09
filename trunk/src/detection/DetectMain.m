function plateCoords = DetectMain(inputImage)

  % If methods do not agree, candidates need to have
  % a score less or equal to this to be selected
  % A setting of 0 returns no candidate unless methods agree
  maxScoreForSingleCandidate = 100;

  %showImages = false;
  showImages = true;

  % Read image from file
  origImage = rgb2gray(imread(inputImage));



  % High contrast blocks
  %f1c = DetectCStretch(inputImage);
  [candCoords(1,1:4), candCoords(1,5)] = DetectCStretch(inputImage);

  % Finds candidates based on sameness
  %f2c = DetectSameness(inputImage);
  [candCoords(2,1:4), candCoords(2,5)] = DetectSameness(inputImage);

  % Finds candidates based on avg filter 
  %f3c = DetectContrastAvg(inputImage);
  [candCoords(3,1:4), candCoords(3,5)] = DetectContrastAvg(inputImage);

  % Finds candidates based on freq analysis 
  %f4c = DetectPlateness(inputImage);
  [candCoords(4,1:4), candCoords(4,5)] = DetectPlateness(inputImage);

  % Reduces image to 8 colors 
  %f5c = DetectQuant(inputImage);
  [candCoords(5,1:4), candCoords(5,5)] = DetectQuant(inputImage);



  % Remove zero candidates [ 0 0 0 0 0]
  candCoords = reshape(nonzeros(candCoords),[],5);

  %%%%%%%%%%%%%%%%%%%%  
  % Select candidate %
  %%%%%%%%%%%%%%%%%%%%


  % Add columns to hold agreement level and candidates agreed with
  % for each candidate we then have
  % [ minX, maxX, minY, maxY, score, agreement, cand1, cand2, cand3, cand4, cand5 ]
  candCoords(:,6:11) = 0;

  %candCoords 

  % How many candidates are we looking at?
  noOfCandidates = size(candCoords,1);



  % Loop through candidates and calc how
  % many components agree with each component
  % Too agree is to have center within component
  for i = 1:noOfCandidates % cand to mark
    for j = 1:noOfCandidates % looking at cand
      thisCenter = [ sum(candCoords(j,1:2))/2, sum(candCoords(j,3:4))/2 ];
      %thatCenter = [ sum(candCoords(i,1:2))/2, sum(candCoords(i,3:4))/2 ];
      % We want to check the center of this with a smaller that
      % so we only get agreement if the candidates are "really" close
      thatWidthMod = 0.1 * (candCoords(i,2) - candCoords(i,1));
      thatHeightMod = 0.1 * (candCoords(i,4) - candCoords(i,3));
    
      % Is center of comp j within comp i?
      %if thisCenter(1) > candCoords(i,1) && thisCenter(1) < candCoords(i,2) && ...
      %   thisCenter(2) > candCoords(i,3) && thisCenter(2) < candCoords(i,4)
      % Stricter version of agreement

      if thisCenter(1) > candCoords(i,1) + thatWidthMod  && ...
         thisCenter(1) < candCoords(i,2) - thatWidthMod  && ...
         thisCenter(2) > candCoords(i,3) + thatHeightMod && ...
         thisCenter(2) < candCoords(i,4) - thatHeightMod
          
         % Register agreement occurence
         candCoords(i,6) = candCoords(i,6) + 1; % Register agreement
         % Register who agreed with me (i)           
         candCoords(i,6+j) = j;

      end % if agreement
      
    end % inner
  end % outher

  %candCoords
 
  %%%%%%%%%%%%%%%%%%%%%%%%%
  % Decide on a candidate %
  %%%%%%%%%%%%%%%%%%%%%%%%%


  % Agreement level
  agLev = max(max(candCoords(:,6)));

  if noOfCandidates == 1
    % We have only one candidate.
    % We will return it
    % THIS NEVER HAPPENS IG GETBESTCANDIDATE ALWAYS RETURNS A CANDIDATE
    if candCoords(bestCandidate,5) <= maxScoreForSingleCandidate
      plateCoords = candCoords(1,1:4);
    else
      % Candidates was not low enough, so we ruturn nothing
      plateCoords = [ 0 0 0 0 ];
    end
    
  elseif agLev == 1
    % two or more candidates disagree

    % Find the candidate with the lowest score
    bestCandidate = find(candCoords(:,5) == min(candCoords(:,5)));
    
    if candCoords(bestCandidate,5) <= maxScoreForSingleCandidate
      % Return coordinates of candidate with lowest score
      plateCoords = candCoords(bestCandidate,1:4);
    else
      % Candidates was not low enough, so we ruturn nothing
      plateCoords = [ 0 0 0 0 ];
    end


  elseif agLev >= 2
    % Two or more candidates agree


    
    % We could have two different groups with the same
    % level af agreement
    % If the number of candidates with the maximum agreelevel
    % is higher than the agree level, we must have 2 groups
    % of agreeing candidates
    if length(find(candCoords(:,6) == agLev)) > agLev 
      % Two groups with agreement level = 2
      candCoords

      % Remove candidates that agree with less number of candidates than
      % the agreement level
      %candCoords = candCoords(find(candCoords(:,6) == agLev),:);
      
      % Create vektor showing if candidates agree with candidate 1
      % 1 == match, 0 == no match 
      agreesWithCand1 = (candCoords(:,7) == candCoords(1,7))  & ...
      (candCoords(:,8)  == candCoords(1,8))  & ...
      (candCoords(:,9)  == candCoords(1,9))  & ...
      (candCoords(:,10) == candCoords(1,10))  & ...
      (candCoords(:,11) == candCoords(1,11));

      % Extract candidates for group 1
      group1 = candCoords(find(agreesWithCand1 == 1),:)

      % Extract candidates for group 2
      group2 = candCoords(find(not(agreesWithCand1) == 1),:)
       
      
      % Return candidate for group with best mean score
      if mean(group1(:,5)) < mean(group2(:,5))
        % Group1 has lowest score
        plateCoords = [ min(group1(:,1)) max(group1(:,2)) ... 
                      min(group1(:,3)) max(group1(:,4)) ]; 
      else
        plateCoords = [ min(group2(:,1)) max(group2(:,2)) ... 
                      min(group2(:,3)) max(group2(:,4)) ]; 
      end

    else
      % One group

      % Get the indexes of rows in the candCoords
      % matrix that have the maximum agree level
      agRows = find(candCoords(:,6) == agLev);

      % Get the list of candidates that agree
      agCands = nonzeros(candCoords( agRows(1), 7:11));

      % Get the list of coords of the candidates we'll use
      goodCands = candCoords(agCands,1:4);

      plateCoords = [ min(goodCands(:,1)) max(goodCands(:,2)) ... 
                      min(goodCands(:,3)) max(goodCands(:,4)) ]; 
    end

  else
    % No agreement between candidates
    plateCoords = [ 0 0 0 0 ];
  end




  if showImages

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


    % Plot center of candidates with score
    for i = 1:noOfCandidates
      %plot(sum(candCoords(i,1:2))/2, sum(candCoords(i,3:4))/2,'ro');
      text(sum(candCoords(i,1:2))/2, sum(candCoords(i,3:4))/2, ... 
      int2str(candCoords(i,5)), 'Color', [1 0 0]);
    end

    hold off;
    
  end

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
