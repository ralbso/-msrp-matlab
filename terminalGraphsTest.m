%dataDir = dir('C:\vr\vroutput\*.csv');

sessionData = getLatestFile('/Users/Raul/*.csv');
filePath = fullfile('Users', 'Raul', sessionData);

fileID = fopen(filePath, 'r');

% read .csv with session data
data = textscan(fileID, '%f %f %f %f %f %f %f %f %f', 'Delimiter', ';');

pos = [data{2}]
numTrials = [data{7}]
numlicks = [data{8}]

figure(1)
for trial = 1:numTrials
 plot(pos,trial,'+')
 hold on
end
xlabel('distance (cm)')
ylabel('trial number')
hold off


fclose(fileID);