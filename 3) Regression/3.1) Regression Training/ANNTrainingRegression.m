%------------------G. Etsias July 31st 2018-------------------------------%
% 1) Current Script Creates a feedforward Neural Network with 10 Neurons and 
%    3 hidden layer.
% 2) Script is executed after RegressionTrainingData.m
clc
trainn=DATA(:,1:2);
goall=DATA(:,3);
trainn=trainn';
goall=goall';
net1 = feedforwardnet([10 10 10]);
net2 = train(net1,trainn,goall,'useParallel','yes','showResources','yes');

