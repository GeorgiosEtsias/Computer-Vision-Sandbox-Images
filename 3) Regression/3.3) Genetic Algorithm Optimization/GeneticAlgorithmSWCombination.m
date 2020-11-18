%----------------G.Etsias July-05-2019------------------------------------%
% Genetic Algorithm SW Prediction Combination
clear
clc
tic
%Load the ML Prediction and actual values of SW concentrations 
load('PredictionC0')
load('PredictionC100')
load('RealSW')
%=========================================================================%
%The GA's objective function has 5 variables
% x(1)= SW percentage that only PerfectC0% is taken into acount 
%(starting value 0)
% x(2)= SW percentage that linear interopolation between PerfectC0% and
% averaging(0%-100%)is best(starting value x(1))
% x(3)= npercentage that averaging PerfectC0%-PerfectC100%)is best
%(starting value x(1)+x(2))
% x(4)= SW percentage that linear interopolation between averaging(0%-100%)
% & PerfectC0 is best(starting value x(1)+x(2)+x(3))
% x(5)= SW percentage that only PerfectC100% is taken into acount 
%(starting value x(1)+x(2)+x(3)+x(4))
%=========================================================================%
comb=zeros(5,3);
prf=zeros(1,3);
for i=1:3

% Determining upper and lower bounds for the 5 variables.
% In effect for ALL the generations.
lb = [0 0 0 0 0];
ub = [100 100 100 100 100];
%-------------------------------------------------------------------------%
% The initial range restricts the range of the points in the initial 
% population. Range does not affect subsequent generations.
%-------------------------------------------------------------------------%

%Manually set GA options: population, generations and plotting best
%solution, with custom plot function
opts = optimoptions(@ga, ...
                   'PopulationSize', 500, ...
                   'MaxGenerations', 100, ...
                   'EliteCount', 2, ...
                   'FunctionTolerance', 1e-8, ...
                   'PlotFcn', @gaplotbestf);
%------------------------------------------------------------------------%
[xbest,ybest,exitflag]= ga(@ObjectiveSWcombination, 5,...
[1,1,1,1,1;-1,-1,-1,-1,-1], [100;-100], [], [], lb, ub, [], [ 1 2 3 4 5], opts);
%------------------------------------------------------------------------%
%Explaning GA command
%A, b: Since equalities are NOT permitted for a ga with integer variables
%we had 100=<x1+x2+x3+x4+x5=<100 instead
%Aeq, beq: No linear equalities exist: 3rd-4th: []
%nonlcon: No  no nonlinear constraints exist: 7th: []
%IntCon [1 2 3 4]: makes all variables integers
%opts: using the specified options
comb(:,i)=xbest;
prf(:,i)=ybest;

end
toc