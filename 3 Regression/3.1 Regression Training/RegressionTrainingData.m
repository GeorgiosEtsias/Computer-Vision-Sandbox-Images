%-------------------G.Etsias February 28-2019-----------------------------%
% Prepartion of data for ANN regression training, training ANN in the mean 
% LI of each calibration image%
% In total 3*8=24 calibration concentrations were used
clear
clc
%% Load variables ---
%Load the 3 datasets ( Based on values of G )
load('Cal780G');
load('Cal1090G');
load('Cal1325G');

%% Manualy-set variables 
naquifers=3; %number of aquifers
ncalibrations=8; %number of calibrations
plotLI=0; % Set plotLI==1 to plot the 24 values of training light intensity

% Number of pixels that are not full of beads and are to be ignored.
%If sandbox full of glass pixlim=1, also pixlim=1 for intial investigations!!
pixlim=1; % full aquifers
% If homogenization procedur occures homog=1 if not homog=0
homog=1;

%% Combining the training datasets
sizeia = size(Cal780G);
npixels = sizeia(1,1)*sizeia(1,2);
npts = naquifers*ncalibrations; % Totalumber of calibration images
%Derive the LI data for C= 0% - 100% and bead sizes 780um-1090um-1325um
avgimgarea=zeros(sizeia(1),sizeia(2),sizeia(3)*3); 
avgimgarea(:,:,1:ncalibrations)=Cal780G(:,:,1:end);
avgimgarea(:,:,ncalibrations+1:2*ncalibrations)=Cal1090G(:,:,1:end);
avgimgarea(:,:,2*ncalibrations+1:3*ncalibrations)=Cal1325G(:,:,1:end);

%% Mean Homo Factor and mean LI value calcualtion
% Homogenising the calibration figures, according to the light Intrensity
% irregularities in the ALL the calibration images

realimgarea=avgimgarea(pixlim:end,:,:); 
M=zeros(1,npts);
for i= 1:npts
M(i)=mean2(realimgarea(:,:,i));%M is key for assigning perfect C=0% & C=100%
end

% Calculating the Homogenizing Factor for each cal. image, then finding
% mean values of it
HomoFactor=zeros(sizeia(1,1)-pixlim+1,sizeia(1,2),npts);
 for k=1:npts
  for i=1:sizeia(1,1)-pixlim+1
    for j= 1:sizeia(1,2)
    HomoFactor(i,j,k)=realimgarea(i,j,k)/M(k);
    end
   end
 end
 
 %Calculating the mean values of Homogenizing Factor along the 3rd
 %dimension
MeanHomoFactor=mean(HomoFactor,3); %To be used on training predictions
%MeanHomoFactor=HomoFactor;
for i= 1:npts
realimgarea(:,:,i)=realimgarea(:,:,i)./MeanHomoFactor;%M is key for assigning perfect C=0% & C=100%
end

for i= 1:npts
M(i)=mean2(realimgarea(:,:,i));%M is key for assigning perfect C=0% & C=100%
end

%% Dataset of mean light intensities 
dmaLI=ones(sizeia(1),sizeia(2),npts);
for i=1:npts
 dmaLI(:,:,i)=dmaLI(:,:,i)*M(i);   
end

%% Plotting the homogenized trimmed images
% for each one of the investigated bead sizes
if plotLI==1
for j = 1:naquifers
    figure (j)
    for i=1:ncalibrations
   subplot(ncalibrations/2,2,i) 
   imagesc(dmaLI(:,:,i+((j-1)*ncalibrations)))
    axis equal
    axis tight
    xlabel('pixels')
    ylabel('pixels')
    
    caxis([0 255])
    colormap(jet(256))
    text('Units','points','VerticalAlignment','bottom',...
    'HorizontalAlignment','center',...
    'Rotation',90,...
    'String','Light Intensity',...
    'Position',[350 30 0]); 
end
end
end

%% Training data: input variables 2, output variable 1
% Bead structure 780,1090,1325
BD(1:ncalibrations,1)=ones(ncalibrations,1).*780;
BD(ncalibrations+1:2*ncalibrations)=ones(ncalibrations,1).*1090;
BD(2*ncalibrations+1:3*ncalibrations)=ones(ncalibrations,1).*1325;

% Saltwater clibration concentrstions 
SW(1:ncalibrations,1)=[0;5;10;20;30;50;70;100];
SW(ncalibrations+1:2*ncalibrations,1)=SW(1:ncalibrations);
SW(2*ncalibrations+1:3*ncalibrations,1)=SW(1:ncalibrations);

 for i=1:npts
  LI=dmaLI(:,:,i);
  LI=reshape(LI,[],1); % with reshape we make LI a single column.
  BD1=BD(i);
  BD1=repmat(BD1,npixels,1);
  SW1=SW(i);
  SW1=repmat(SW1,npixels,1);
  %DATA(i).train=[BD1,LI,SW1];
  DATA((i-1)*npixels+1:i*npixels,:)=[BD1,LI,SW1];
  clear LI BD1 SW1
 end

%% Prepare data for MatLab-Regreesion-Learner App(optional) 
TotalData = array2table(DATA,...
    'VariableNames',{'BeadSize','LightIntensity','SW'});