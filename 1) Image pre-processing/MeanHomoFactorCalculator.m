% ---------------G.Etsias January-18-2019-------------------------------- %
% --Based on (AIOBeadStructureTrainingDataSTD)for greyscale images------- %
% -----Needs a large amount of freshwater only homogeneous aquifers------ %
%=========================================================================%
% --------------(G.Etsias September-12-2018)----------------------------- %
% -Calculates the mean homo factor for a series of Homogeneous Aquifers-- %
% ======================================================================= % 
clear
clc
%% Plottingptions 
plotimages=1; 
% if original vs homogenised images are to be plotted set plotimages=1

%% Loading datasets
npts=12; %Number of homogeneous aquifers (one for each bead size)
pixlim=1; %Removing upper aquifer part if needed (unsaturated region)
%Load the Homogeneous Freshwater Data array structure 
load('subset1');
load('subset2');
load('subset3');
load('subset4');

for i=1:3
 trainingData(i)=subset1(i);
 trainingData(i+3)=subset2(i);
 trainingData(i+6)=subset3(i);
 trainingData(i+9)=subset4(i);
end
%Determine the dimensions of each specific image subset.
sizeia = size(trainingData(1).R);

%% Mean Homo Factor calcualtion
% Homogenising the calibration figures, according to the light Intrensity
% irregularities in the all the calibration images 
Homogenising=1; %If homogenisation applies set Homogenising=1

if Homogenising==1
%4 different Homofactors calculated: 1)R, 2)G, 3)B & 4)Greyscale
Mean=zeros(npts,4);
%Averaging values for each image 
for i= 1:npts % npts=number of images
Mean(i,1)= mean2(trainingData(i).R(:,:));
Mean(i,2)= mean2(trainingData(i).G(:,:));
Mean(i,3)= mean2(trainingData(i).B(:,:));
Mean(i,4)= mean2(trainingData(i).greyscale(:,:));
end
% Calculating the Homogenizing Factor for each cal. image, then finding
% mean values of it
HomoFactor=zeros(sizeia(1,1)-pixlim+1,sizeia(1,2),4,npts);
for k=1:npts
for i=1:sizeia(1,1)-pixlim+1
    for j= 1:sizeia(1,2)
    HomoFactor(i,j,1,k)=trainingData(k).R(i,j)/Mean(k,1);
    HomoFactor(i,j,2,k)=trainingData(k).G(i,j)/Mean(k,2);
    HomoFactor(i,j,3,k)=trainingData(k).B(i,j)/Mean(k,3);
    HomoFactor(i,j,4,k)=trainingData(k).greyscale(i,j)/Mean(k,4);
    end
end
end
 
%Calculating the mean values of Homogenizing Factor along the 3rd dimension
MeanHomoFactorRGBG=zeros(sizeia(1,1),sizeia(1,2),4);
for i=1:4
MeanHomoFactorRGBG(:,:,i)=mean(HomoFactor(:,:,i,:),4);
end
end
save('MeanHomoFactorRGBG','MeanHomoFactorRGBG')

%% Plotting the homogenized vs original images
if plotimages==1
for i = 1:npts
   figure(i)
   subplot(2,1,1)
    imagesc(trainingData(i).greyscale./MeanHomoFactorRGBG(:,:,4));
      axis equal
    axis tight
    xlabel('pixels')
    ylabel('pixels')
    title('homogenized')
    caxis([0 255])
    c = colorbar;
    %colormap gray
    colormap(jet(256))
    % Creating Colorbar tittle with proper possition and orienation.
    text('Units','points','VerticalAlignment','bottom',...
    'HorizontalAlignment','center',...
    'Rotation',90,...
    'String','Light Intensity',...
    'Position',[350 30 0]); 
   
   subplot(2,1,2)
   imagesc(trainingData(i).greyscale);
    axis equal
    axis tight
    xlabel('pixels')
    ylabel('pixels')
    title('original')
    caxis([0 255])
    c = colorbar;
    colormap(jet(256))
    text('Units','points','VerticalAlignment','bottom',...
    'HorizontalAlignment','center',...
    'Rotation',90,...
    'String','Light Intensity',...
    'Position',[350 30 0]);     
end
end
