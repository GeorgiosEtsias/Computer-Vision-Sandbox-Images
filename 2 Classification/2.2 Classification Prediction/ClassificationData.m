% ---------------G.Etsias January-18-2019-------------------------------- %
% Uses color images to derive data fit for Bead Structure Prediction, 
% that can be used as training or prediction data for ANNs in script or in 
% conjuction with MatLab Classification Learner app.
clear 
clc

%% Loading variables 
npts=3; %Number of homogeneous aquifers (one for each bead size)
pixlim=1; %Foul aquifers!
%Load data-set
load('testdataset');
trainingData=testdataset;
%Determine the dimensions of each specific image subset.
sizeia = size(trainingData(1).R);
%Load the homogenization factor
load('MeanHomoFactorRGBG')
% The real life size each specific pixel represents
pixelsizem=0.0001054384;

%% User-defined plotting options 
homogenisation=1;
%If MeanhomoFactorRGBG is to be applied set homogenisation=1
plotstds=0;
%If standard deviations are to be plotted set plotstds=1
plotspec=0;
%If 'specific plots' are to be plotted set plotstds=1

%% Keep original unhomogenised images
trainingDataRaw=trainingData;

%% Image Homogenisation
if homogenisation==1 
   for i = 1:npts
    trainingData(i).R=trainingData(i).R./MeanHomoFactorRGBG(:,:,1);    
    trainingData(i).G=trainingData(i).G./MeanHomoFactorRGBG(:,:,2);
    trainingData(i).B=trainingData(i).B./MeanHomoFactorRGBG(:,:,3);
    trainingData(i).greyscale=...
        trainingData(i).greyscale./MeanHomoFactorRGBG(:,:,4);
   end
end

%% Calculating light intensity standard deviation stdfilt(I,nhood) 
% stdfilt is a Matlab built-in equation that caluclates standard 
% deviation within a rectuangukar batch of nhood pixel dimensions
nhood=ones(15,15);
   for i = 1:npts
    stdData(i).R=(stdfilt(trainingDataRaw(i).R,nhood)).^2;    
    stdData(i).G=(stdfilt(trainingDataRaw(i).G,nhood)).^2;
    stdData(i).B=(stdfilt(trainingDataRaw(i).B,nhood)).^2;
    stdData(i).greyscale=(stdfilt(trainingDataRaw(i).greyscale,nhood)).^2;
   end
% plotting    
if plotstds==1  
   for i = 1:npts
   figure(i)
    imagesc([0 sizeia(1,2)]*pixelsizem,[0 sizeia(1,1)]*pixelsizem,flipud(stdData(i).B))
    set(gca,'YDir','Normal')
      axis equal
    axis tight
    xlabel('X(m)')
    ylabel('Z(m)')
    caxis([0 50])
    c = colorbar;
    colormap(jet(256))
    text('Units','points','VerticalAlignment','bottom',...
    'HorizontalAlignment','center',...
    'Rotation',90,...
    'String','Var(Grey)',...
    'Position',[350 30 0])
   end
end

%% Data preparation for neural training
% Create a single matrix including the data of all the 3 Array Structures
% Scripts calculates all 8 different image variables:
% R, G, B, Grey, std(R), std(G), std(B), std(Grey)
% This way the user can choose optimum variable combination for neural 
% training.
clc
nmodpixels= (sizeia(1,1)-pixlim+1)*(sizeia(1,2));

%% Input Variables
for i=1:3 % coresponding to the 3 training images
% Red column
LI=trainingData(i).R;
R(nmodpixels*(i-1)+1:nmodpixels*(i),1)=reshape(LI,[],1);
% Green column
LI=trainingData(i).G;
G(nmodpixels*(i-1)+1:nmodpixels*(i),1)=reshape(LI,[],1);
% Blue column
LI=trainingData(i).B;
B(nmodpixels*(i-1)+1:nmodpixels*(i),1)=reshape(LI,[],1);
% Greyscale column
LI=trainingData(i).greyscale;
Grey(nmodpixels*(i-1)+1:nmodpixels*(i),1)=reshape(LI,[],1);
% -----standard deviations R, G, B, greyscale --------- %
% stdR column
LI=stdData(i).R;
stdR(nmodpixels*(i-1)+1:nmodpixels*(i),1)=reshape(LI,[],1);
% stdG column 
LI=stdData(i).G;
stdG(nmodpixels*(i-1)+1:nmodpixels*(i),1)=reshape(LI,[],1);
% stdB column
LI=stdData(i).B;
stdB(nmodpixels*(i-1)+1:nmodpixels*(i),1)=reshape(LI,[],1);
% stdgreyscale column
LI=stdData(i).greyscale;
stdGrey(nmodpixels*(i-1)+1:nmodpixels*(i),1)=reshape(LI,[],1);
end

%% Output variable = Bead size diameter
%BS=[780];
BS780=repmat(780,nmodpixels,1);
%BS=[1090];
BS1090=repmat(1090,nmodpixels,1);
%BS1325=[1325];
BS1325=repmat(1325,nmodpixels,1);
BS(1:nmodpixels,1)=BS780;
BS(nmodpixels+1:2*nmodpixels,1)=BS1090;
BS(2*nmodpixels+1:nmodpixels*3,1)=BS1325;

AllDATA=[R,G,B,Grey,stdR,stdG,stdB,stdGrey,BS];

%% Final training variables
DATAA=[R,G,Grey,stdGrey,BS];% optimum feature combination

%Classes are presented by a 1 in one of the rows zeros in the other.
goalClass=zeros((nmodpixels*3),3); % 3 different bead sizes
goalClass(1:nmodpixels,1)=1;
goalClass((nmodpixels+1):(nmodpixels*2),2)=1;
goalClass(((nmodpixels*2)+1):(nmodpixels*3),3)=1;

%% Correlation between color and standard deviation (scatter plot)
if plotspec==1
%plot - colors
plotcol(:,:,1)=[1 0.5 0.5;1 0.3 0.3; 1 0 0;];
plotcol(:,:,2)=[0.5 1 0.5; 0.3 1 0.3; 0 1 0;];
plotcol(:,:,3)=[0.5 0.5 1;0.3 0.3 1; 0 0 1;];
plotcol(:,:,4)=[0.5 0.5 0.5;0.3 0.3 0.3; 0 0 0;];
for i=1:4
figure (10)
% -- Red -- %
subplot(2,2,i);
scatter(AllDATA(1:nmodpixels,1),AllDATA(1:nmodpixels,i+4),2,plotcol(1,:,i))
hold on
scatter(AllDATA(nmodpixels+1:2*nmodpixels,1),AllDATA(nmodpixels+1:2*nmodpixels,i+4),2,plotcol(2,:,i))
hold on
scatter(AllDATA(2*nmodpixels+1:3*nmodpixels,1),AllDATA(2*nmodpixels+1:3*nmodpixels,i+4),2,plotcol(3,:,i))
% Getting subplot titles and axes
if i==1
    title ('R and standev(R) correlation')
    xlabel('R')
    ylabel('standev(R)')
elseif i==2
    title ('G and standev(G) correlation')
    xlabel('G')
    ylabel('standev(G)')
elseif i==3
    title ('B and standev(B) correlation')
    xlabel('B')
    ylabel('standev(B)')
else
    title ('grey and standev(grey) correlation')
    xlabel('grey')
    ylabel('standev(grey)')
    legend('780um','1090um','1325um')
end
end
end