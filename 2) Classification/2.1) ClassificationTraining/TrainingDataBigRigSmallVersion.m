%-------------------G.Etsias February 28-2019-----------------------------%
%----------------Data Modification Approach (DMA)-------------------------%
%---------Training ANN in the mean LI of each calibration image-----------%
% ---------------------- New Camera, Green LI --------------------------- %
% ======================================================================= %
%----Based on: G.Etsias November 20-2018 version for the old camera-------%
% ======================================================================= %
%---Derive data for training Neural Network to do SW regression analysis--%
%------------------ using 3*8=24 calibration images-----------------------%
%-----------Input variables X,Y,BS,LI(G) output SW C%---------------------%
% ======================================================================= %
clear
clc
%% --- Variables ---
%Load the calibration dataset ( Based on values of G )
load('SPCalibrationsG');
SW=[0,5,10,20,30,50,70,100]; %calibration concentrations
%% Resizing - 10 times smaller
for i=1:8
   SPCalibrationsGsmall(:,:,i)= imresize(SPCalibrationsG(:,:,i),0.1);
end
save('SPCalibrationsGsmall','SPCalibrationsGsmall')

%% === Variables to manually set ========================================= %
npts = 8; % No. of calibration images
% Number of pixels that are not full of beads and are to be ignored.
%If sandbox full of glass pixlim=1, also pixlim=1 for intial investigations!!
pixlim=1; % foul aquifers
% If homogenization procedur occures homog=1 if not homog=0
homog=1;

sizeia = size(SPCalibrationsGsmall);
npixels = sizeia(1,1)*sizeia(1,2);

%Derive the LI data for C= 0% - 100% and bead sizes 780um-1090um-1325um
avgimgarea=SPCalibrationsGsmall; 

%% Mean Homo Factor and Mean LI Values
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

%% --- Data Set of mean LI --- %%

dmaLI=ones(sizeia(1),sizeia(2),npts);
for i=1:npts
 dmaLI(:,:,i)=dmaLI(:,:,i)*M(i);   
end

%% Plotting the homogenized trimmed images
for i = 1:npts
   subplot(2,4,i)
   imagesc(dmaLI(:,:,i))
    axis equal
    axis tight
    xlabel('pixels')
    ylabel('pixels')
    caxis([0 255])
    colormap(jet(256))
    % Creating Colorbar tittle with proper possition and orienation.
    text('Units','points','VerticalAlignment','bottom',...
    'HorizontalAlignment','center',...
    'Rotation',90,...
    'String','Light Intensity',...
    'Position',[350 30 0]); 
end
 
%% --- DMA training Data ---
for i=1:npts
  LI=dmaLI(:,:,i);
  LI=reshape(LI,[],1); % with reshape we make LI a single column.
  SW1=SW(i);
  SW1=repmat(SW1,npixels,1);
  DATA(i).train=[LI,SW1];
  clear LI SW1
end
DATAA=[DATA(1).train;DATA(2).train;DATA(3).train;DATA(4).train;...
    DATA(5).train;DATA(6).train;DATA(7).train;DATA(8).train];

%% MatLab Regreesion Learner
TotalData = array2table(DATAA,...
    'VariableNames',{'LightIntensity','SW'});

%% Neural Network Training and Goal Data
% Training data classification and regression NN
Trainn=DATAA(:,1);
% Goal for regression analysis NN
goalReg=DATAA(:,2);
% Goal for classification NN
% For every different bead size involved there is an extra column.