%-------------------G.Etsias February 28-2019-----------------------------%
%Prepartion of data for ANN regression testing, SW concentration prediction
clear
clc
%% Load variables
load('Layered3Test1')%Test aquifer dataset
load('Layered3SW0') %Freshwater-only image of test aquifer
load('Layered3SW100') %Saltwater-only image of test aquifer
load ('Str10907801090')%Bead Structure of the heterogneous aquifers
% Load mean values of LI
load('M') % mean light intensities from the training data
% Load Homogenisation Factor
load ('MeanHomoFactor') %from the training data DMA
pixelsizem=0.0001054384;

%% Choose test case 
% In case multiple test aquifers are loaded
TestCase=Layered3Test1;
TestNumber=size(TestCase);
Structure=Str10907801090;

%% Manually-set variables
npts = 24; % No. of calibration images
% Number of pixels that are not full of beads and are to be
% ignored. (If sandbox full of glass pixlim=1, also pixlim=1 for intial investigations!!)
pixlim=1; % full aquifers
% If homogenization procedur occures homog=1 if not homog=0
homog=1;
% Set plot perf =1 to plot the perfect C=0% and C=100% aquifers
plotperf=1 ;

%% Forming the testing dataset
sizeia = size(TestCase);
npixels = sizeia(1,1)*sizeia(1,2);
%Derive the LI data for C= 0% - 100% and bead sizes 780um-1090um-1325um
avgimgarea= zeros(sizeia(1),sizeia(2),npts); 
avgimgarea(:,:,1)=Layered3SW0; 
avgimgarea(:,:,2:1+TestNumber(3))= TestCase(:,:,1:end);
avgimgarea(:,:,24)=Layered3SW100;

%% Image homogenization
for i=1:npts
        avgimgarea(:,:,i)=avgimgarea(:,:,i)./MeanHomoFactor;
end

%% Cange Factor caluclation ---- %
changeC0=zeros(sizeia(1,1),sizeia(1,2));
changeC100=zeros(sizeia(1,1),sizeia(1,2));
% Calculation of change factor for the heterogeneous aquifer
    for i=1:sizeia(1,1)
        for j=1:sizeia(1,2)
            if Structure(i,j)==780
                changeC0(i,j)=(avgimgarea(i,j,1)./M(1));
                changeC100(i,j)=(avgimgarea(i,j,24)./M(8));
            elseif Structure(i,j)==1090
                changeC0(i,j)=(avgimgarea(i,j,1)./M(9));
                changeC100(i,j)=(avgimgarea(i,j,24)./M(16));
            elseif  Structure(i,j)==1325
                changeC0(i,j)=(avgimgarea(i,j,1)./M(17));
                changeC100(i,j)=(avgimgarea(i,j,24)./M(24));
            end
        end
    end

%% Perfect c=0% and c=100% data subsets
% Perect C=0
for i=1:24
   avgimgareaC0(:,:,i)=avgimgarea(:,:,i)./changeC0;
end

% Perect C=100
for i=1:24
   avgimgareaC100(:,:,i)=avgimgarea(:,:,i)./changeC100;
end

%% Plot modified data 
if plotperf==1
 for i = 1:npts
   figure(i)
    subplot(2,1,1)
    imagesc([0 sizeia(1,2)]*pixelsizem,[0 sizeia(1,1)]*pixelsizem,flipud...
       (avgimgareaC0(pixlim:end,:,i)))
    set(gca,'YDir','Normal')
    axis equal
    axis tight
    xlabel('pixels')
    ylabel('pixels')
    caxis([0 255])
    c = colorbar;
    colormap(jet(256))
    xlabel('X(m)')
   ylabel('Z(m)')
    text('Units','points','VerticalAlignment','bottom',...
    'HorizontalAlignment','center',...
    'Rotation',90,...
    'String','Light Intensity',...
    'Position',[350 30 0]);
    title ('Perfect C=0%')
   
    subplot(2,1,2)
    imagesc([0 sizeia(1,2)]*pixelsizem,[0 sizeia(1,1)]*pixelsizem,flipud...
       (avgimgareaC100(pixlim:end,:,i)))
    set(gca,'YDir','Normal')
    axis equal
    axis tight
    xlabel('pixels')
    ylabel('pixels')
    caxis([0 255])
    c = colorbar;
    colormap(jet(256))
    xlabel('X(m)')
    ylabel('Z(m)')
    text('Units','points','VerticalAlignment','bottom',...
    'HorizontalAlignment','center',...
    'Rotation',90,...
    'String','Light Intensity',...
    'Position',[350 30 0]);
    title ('Perfect C=100%')  
end
end

%% ANN regression prediction data 
BD=Structure; % Heterogeneous Structure
BD=reshape(BD,[],1);
 for i=1:npts
  BD=Structure; % Heterogeneous Structure
  BD=reshape(BD,[],1);
  %Light intensities
  LI0=avgimgareaC0(:,:,i);
  LI0=reshape(LI0,[],1); 
  LI100=avgimgareaC100(:,:,i);
  LI100=reshape(LI100,[],1); 
  DATAC0((i-1)*npixels+1:i*npixels,:)=[BD,LI0];% Perfect c=0%
  DATAC100((i-1)*npixels+1:i*npixels,:)=[BD,LI100];% Perfect c=100%
  clear LI0 LI100 BD 
 end