%----------------G.Etsias September-03-2018-------------------------------%
%---------------------Objective Function----------------------------------%
%Be used as an objective function for NN architecture
%optimization using a Genetic Algorithm.
%The function is the performance of a up to 3 layers feedforward NN 
%Each layer can have its own number of neurons
%-----------------------Version 2(03/09/18)-------------------------------%
%---------Includes solspc criterion calculation---------------------------%
%-----------------------Version 3(04/09/18)-------------------------------%
%-Calculates NN weights and  biases and determines max epochs accordingly-%
%---This determines the amount of maximum epochs for each architecture----%
%-----------------------Version 4(06/09/18)-------------------------------%
%---Saves the best network and pass it from generation to generation------%
%-Since NN is a heuristic model,same archtecture = different performance--%
%-----------------------Version 5(07/09/18)-------------------------------%
%---Determines maximum training time in seconds for every Neural Network--%
%---------The introduced part in version 3 becomes obsolete---------------%
%-----------------------Version 6(10/09/18)-------------------------------%
%Multiplyes the value of RMS of testing subset,to that of the whole dataset%
%This makes the generalization ability of each trained ANN more important-%
%-----------------------Version 7(11/09/18)-------------------------------%
%Saves the tr.state, performance, regression & error histogram plots of---% 
%-----the best network, to be retrived at the end of the GA---------------%

function [Error,x] = ObjectiveSWcombination(x)
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

%%
sizeia=size(PredictionC0);
pixelsizem=0.0001054384;
ALL=cat(4,PredictionC0,PredictionC100);
CombinationPrediction=mean(ALL,4);
for k=1:sizeia(3)
    for i=1:sizeia(1)
       for j=1:sizeia(2)
            if PredictionC100(i,j,k)>=(x(1)+x(2)+x(3)+x(4))
                CombinationPrediction(i,j,k)=PredictionC100(i,j,k);
            elseif PredictionC0(i,j,k)<=x(1)
                CombinationPrediction(i,j,k)=PredictionC0(i,j,k);
            elseif PredictionC100(i,j,k)>=(x(1)+x(2)+x(3))
                   CombinationPrediction(i,j,k)=(((PredictionC100(i,j,k)-x(5))/(2*x(4)))*PredictionC100(i,j,k))+...
                       ((1-((PredictionC100(i,j,k)-x(5))/(2*x(4))))*PredictionC0(i,j,k));
            elseif PredictionC0(i,j,k)<=(x(1)+x(2))
                CombinationPrediction(i,j,k)= (((1-((2*x(2))-(PredictionC0(i,j,k)-x(1)))/(2*x(2))))*PredictionC100(i,j,k))+...
                       (((2*x(2))-(PredictionC0(i,j,k)-x(1)))/(2*x(2)))*PredictionC0(i,j,k);
            end
        end
    end
end
%  Calculating MSE for each on of the 8 Calibration Concentrations
error=zeros(24,1);
for k=1:sizeia(3)
    error(k)=immse(RealSW(:,:,k),CombinationPrediction(:,:,k)); 
end
% Calculating MSE per homogeneous aquifer 780um, 1090um 1325um
Error780=0.05*((error(1)+error(2))/2)+0.05*((error(2)+error(3))/2)+...
      0.1*((error(3)+error(4))/2)+0.1*((error(4)+error(5))/2)+...
      0.2*((error(5)+error(6))/2)+0.2*((error(6)+error(7))/2)+...
      0.3*((error(7)+error(8))/2);
Error1090=0.05*((error(1+8)+error(2+8))/2)+0.05*((error(2+8)+error(3+8))/2)+...
      0.1*((error(3+8)+error(4+8))/2)+0.1*((error(4+8)+error(5+8))/2)+...
      0.2*((error(5+8)+error(6+8))/2)+0.2*((error(6+8)+error(7+8))/2)+...
      0.3*((error(7+8)+error(8+8))/2);
Error1325=0.05*((error(1+16)+error(2+16))/2)+0.05*((error(2+16)+error(3+16))/2)+...
      0.1*((error(3+16)+error(4+16))/2)+0.1*((error(4+16)+error(5+16))/2)+...
      0.2*((error(5+16)+error(6+16))/2)+0.2*((error(6+16)+error(7+16))/2)+...
      0.3*((error(7+16)+error(8+16))/2);

Error=(Error780+Error1090+Error1325)/3;
end


