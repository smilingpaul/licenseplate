% Takes a signature, returns plateness integer
function plateness = GetPlateness(sig)


% Calculate plateness (number of times plot crosses avg. value in sig) 

% Average value for sig
% Plates often start and end low, We can move the avg up to try to compensate
sigAvg = 1.0 * (sum(sig)/length(sig));

% How many times have we crossed the avg. sig value
timesCrossed = 0;

% Do we start over or under avg. ?
if sig(1) > sigAvg
 over = true;
else
 over = false;
end

for x = 2:length(sig)
  % Go down
  if over == true && sig(x) <= sigAvg
    timesCrossed = timesCrossed + 1;
    over = false;
  end
  % Go up
  if over == false && sig(x) > sigAvg
    timesCrossed = timesCrossed + 1;
    over = true;
  end
end


% Plateness to return
plateness = timesCrossed;


end
