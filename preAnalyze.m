%UNCOMMENT IN FINAL VERSION
%sessionData = getLatestFile('C:\vr\vroutput\*.csv');

sessionData = 'MTH3_vr1_2017615_1731.csv';

%filePath = fullfile('C:', 'vr', 'vroutput', sessionData); 
filePath = fullfile('Users', 'Raul', 'coding', 'mit', 'harnett', 'msrp-matlab', sessionData);
 
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

%For filtering data and indexing

S = vrWorld == 3;
L = vrWorld == 4;
B = vrWorld == 5;

posShort = pos(S);
posLong = pos(L);
posBB = pos(B);

numTrialsShort = numTrials(S);
numTrialsLong = numTrials(L);
numTrialsBB = numTrials(B);

numLicksShort = numLicks(S);
numLicksLong = numLicks(L);
numLicksBB = numLicks(B);
 
licksShort = find(numLicksShort); 
licksLong = find(numLicksLong); 
licksBB = find(numLicksBB);

% noLick = find(~numLicks);           % indexes of no licks 
% shortTrial = find(vrWorld == 3);    % indexes of short trials 
% longTrial = find(vrWorld == 4);     % indexes of long trials 
% blackbox = find(vrWorld == 5);      % indexes of black boxes
 
%totalShortTrials = size(unique(numTrials(S)),1); 
%totalLongTrials = size(unique(numTrials(L)),1); 

%Short trials scatter plot
figure(1) 
    plot(posShort(licksShort), numTrialsShort(licksShort), 'bo') 
    xlabel('Position') 
    ylabel('Trial #') 
    title('Short trials') 

%Long trials scatter plot
figure(2) 
    plot(posLong(licksLong), numTrialsLong(licksLong), 'ro') 
    xlabel('Position') 
    ylabel('Trial #') 
    title('Long trials') 

%Black box scatter plot
figure(3)
    plot(posBB(licksBB), numTrialsBB(licksBB), 'co')
    xlabel('Position')
    ylabel('Trial #')
    title('Black box')

fclose(fileID); 