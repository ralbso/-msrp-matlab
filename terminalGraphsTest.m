
%UNCOMMENT NEXT LINE AFTER TESTS ARE DONE
%sessionData = getLatestFile('C:\vr\vroutput\*.csv');
sessionData = ('MTH3_vr1_2017615_1731.csv');
filePath = fullfile('C:', 'vr', 'vroutput', sessionData);

fileID = fopen(filePath, 'r');

%read .csv with session data
data = textscan(fileID, '%f %f %f %f %f %f %f %f %f', 'Delimiter', ';');

%breakdown of .csv contents
t = [data{1}];
pos = [data{2}];
tFrame = [data{3}];
vel = [data{4}];
vrWorld = [data{5}];
valveStat = [data{6}];
numTrials = [data{7}];
numLicks = [data{8}];
wheelVel = [data{9}];

lick = find(numLicks);      % indexes of licks
noLick = find(~numLicks);   % indexes of no licks
shortTrial = find(vrWorld == 3);    % indexes of short trials
longTrial = find(vrWorld == 4);     % indexes of long trials
blackbox = find(vrWorld == 5);      % indexes of black boxes

totalShortTrials = size(unique(numTrials(shortTrial)),1);
totalLongTrials = size(unique(numTrials(longTrial)),1);

figure(1)
for line = data(lick)
    if 
    plot(pos(lick), numTrials(lick), 'o')
    xlabel('Position')
    ylabel('Trial #')
    title('Short trials')
end

figure(2)
if vrWorld(longTrial)
    plot(pos(lick), numTrials(lick), 'o')
    xlabel('Position')
    ylabel('Trial #')
    title('Long trials')
end

fclose(fileID);
