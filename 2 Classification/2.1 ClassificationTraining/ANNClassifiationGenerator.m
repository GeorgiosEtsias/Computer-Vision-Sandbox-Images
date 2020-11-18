%------------------G.Etsias July 31st 2018--------------------------------%
% Using Neural Net Fitting App one cannot use parallel programing toolbox.
% Using Big Data demands Parallel Computing to optimise efficiency. Current
% Script Creates a feedforward Neural Network with 10 Neurons and on hidden
% layer.
clc
trainn=DATAA(:,1:4); %Optimum training data feature combination
goall=goalClass;
trainn=trainn';
goall=goall';
% ANN architecture
% If network has 2 hidden layers  with X&Y number of neurons
% feedforwardnet([X Y])
net1 = patternnet([30 30]);
net1.trainParam.time= 1200; %Determining the maximum training time in secs
%net1.trainParam.goal= 10^(-6);
net2 = train(net1,trainn,goall,'useParallel','yes','showResources','yes');

