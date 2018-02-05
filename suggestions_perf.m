%% Slice long trials
%   This script slices the long number of trials;
%   To get a slice, type trials_indexes(1: trials_indexes(2)-1)
count = 1;
trials_indexes = 1;
for i = 1:length(num_trials)
    if num_trials(i) ~= count
        trials_indexes = [trials_indexes i];
        count = count + 1;
    else
        continue
    end
end
%%
trials_indexes(1:10)
%%
% for j = 1:length(licks)
%     disp(
% end

first_lick = [];
for j = 2:range(num_trials)+1
    licks_slice = licks(trials_indexes(j-1):trials_indexes(j)-1);
    first_lick = [first_lick find(licks_slice,1,'first')];
end