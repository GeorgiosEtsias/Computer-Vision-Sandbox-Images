%--------------------G Etsias January 21st 2019---------------------------%
%1)Script generates bead structure for given homogeneous or heterogeneous 
%  aquifers and is executed after ClassificationData.m.
%2)The trainied ANN and the coresponrding prediction data need to be loaded
%3)Values of 'npts' and 'sizeia' values are determined in the execution of
%  ClassificationData.m
%4)A series of prediction altering operations are executed after the 
%  initial neural prediction. The user can determine which procedures will
%  take place. 3 of the subroutines are incorporated as functions.
%5)Script execution time is relatively long. Manual refinement of
%  predictions might be a viable and faster alternative in many cases.
tic
%% User-defined options
probability=1; % Set probability=1 in order to:
% Determine bead size by its prediction probability
neighbourhood=1; %Set neighbourhood=1 in order to:
% Change predicted Beadsize according to dominant size in the neighbourhood
plotchanges=0; % Set plotchanges=1 in order to:
% Plot the subsequent stages of changing bead structure values
subroutine1=1;% Set subroutine1=1 in order to:
% Modify prediction acording to subroutine 1
subroutine2=0;% Set subroutine2=1 in order to:
% Modify prediction acording to subroutine 2
difussion=0;% Set difussion=1 in order to:
%Aplly 2D anisotropic doifussion

%% ANN prediction generation
clc
load('ANNclassification')%Loading the corresponding trained ANN
net2=ANNclassification;
inputs=DATAA(:,1:4);
inputs=inputs';
outputs = net2(inputs); % The origianal ANN prediction
outputs=outputs';
size2=size(outputs);
pixelsizem=0.0001054384;

%% Applying the bead size values without probability
BS=zeros(size2(1),1);
for i=1: size2(1)
    if outputs (i,1)>=outputs (i,2) && outputs (i,1)>=outputs (i,3)
        BS(i)=780;
    elseif outputs (i,2)>=outputs(i,1) && outputs (i,2)>=outputs (i,3)
        BS(i)=1090;
    elseif outputs (i,3)>=outputs (i,1) && outputs (i,3)>=outputs (i,2)
        BS(i)=1325;
    end
end
predOriginal=reshape(BS,sizeia(1),sizeia(2),npts);  

%% Applying the bead size values acording to probability
BS=zeros(size2(1),1);
for i=1:size2(1)
    if outputs(i,1)>=0.999 % Almost certain prediction
        BS(i)=780;
    elseif outputs(i,2)>=0.999
        BS(i)=1090;
    elseif outputs(i,3)>=0.999
        BS(i)=1325;
     else 
        BS(i)=2000;
    end
end
predProbability1=reshape(BS,sizeia(1,1)-pixlim+1,sizeia(1,2),npts);

%% Calculating dominant classes in the probability image
ProbabilityNEW=predProbability1;% essential part of the transformation
for jj=81:-10:11 %Predetermined size of the square batch that dominant class is calcuated

for k=1:1 %Images to be processed
for i=1:sizeia(1)
for j=1:sizeia(2)
     if predProbability1(i,j,k)==2000
            maxbatch=jj;% the second criteria of if search
            %(if we are closer to the image boundary this can change)
maxnum1=(maxbatch-1)/2;%for a maxbatch*maxbatch batch this is the number we add/substrcut
maxnum2=(maxbatch-1)/2;
maxnum3=(maxbatch-1)/2;
maxnum4=(maxbatch-1)/2;
%---Change the max.batch size if you are closer to the image border-------%
if i-maxnum1<=0 %up
    maxnum1=i-1;
end
if i+maxnum2>=sizeia(1) %down
    maxnum2=sizeia(1)-i;
end
if j-maxnum3<=0 %left
    maxnum3=j-1;
end
if j+maxnum4>=sizeia(2) %right
    maxnum4=sizeia(2)-j;
end

%----------Calculating amount of pixels in each class---------------------%
A=predProbability1(i-maxnum1:i+maxnum2,j-maxnum3:j+maxnum4,k);

class0780=sum(A(:)==780);
class1090=sum(A(:)==1090);
class1325=sum(A(:)==1325);
noclass=sum(A(:)==2000);

%---------------Is there a dominant class? 80% of pixels------------------%
              if class0780>=0.6*(class0780+class1090+class1325+noclass)
                  dominantclass=780;
              elseif class1090>=0.6*(class0780+class1090+class1325+noclass)
                  dominantclass=1090;
              elseif class1325>=0.6*(class0780+class1090+class1325+noclass)
                  dominantclass=1325;
              else
                  dominantclass=2000;
              end
  if dominantclass~=2000
      
           ProbabilityNEW(i,j,k)=dominantclass;
  end
    end
end
end
predProbability2(:,:,k)=ProbabilityNEW(:,:,k); 
%After one column is modified the new values are permanently stored 
end
end

%% Give the unclassified pixels of predProbability2 the values of the original prediction
predProbability3=predProbability2;
for k=1:1 %Images to be processed
for i=1:sizeia(1)
for j=1:sizeia(2)
    if predProbability2(i,j,k)==2000
       predProbability3(i,j,k)=predOriginal(i,j,k);
    end
end
end
end

%% Plotting the various prediction transformations
for i=1:1 %Images to be plotted
% Initial
figure (1)
im(1)= subplot(2,2,1);
imagesc([0 sizeia(1,2)]*pixelsizem,[0 sizeia(1,1)]*pixelsizem,...
    flipud(predOriginal(:,:,i)))
    set(gca,'YDir','Normal')
    axis equal
    axis tight
    colormap(im(1),jet(256))
   caxis([780 1325])
   c = colorbar;
   xlabel('X(m)')
   ylabel('Z(m)')
   title ('Initial Predicted Bead Structure')
   text('Units','points','VerticalAlignment','bottom',...
    'HorizontalAlignment','center',...
    'Rotation',90,...
    'String','Bead Size \mum',...
    'Position',[350 50 0]);

% Probability 
im(2)=subplot(2,2,2);
imagesc([0 sizeia(1,2)]*pixelsizem,[0 sizeia(1,1)]*pixelsizem,...
    flipud(predProbability1(:,:,i)))
    set(gca,'YDir','Normal')
    axis equal
    axis tight
   colormap(im(2),parula)
   caxis([780 2000])
   c = colorbar;
   xlabel('X(m)')
   ylabel('Z(m)')
   title ('Initial Generated Probabilistic Bead Structure')
   text('Units','points','VerticalAlignment','bottom',...
    'HorizontalAlignment','center',...
    'Rotation',90,...
    'String','Bead Size \mum',...
    'Position',[350 50 0]);

% Dominant pixels
im(3)=subplot(2,2,3);
imagesc([0 sizeia(1,2)]*pixelsizem,[0 sizeia(1,1)]*pixelsizem,flipud(predProbability2(:,:,i)))
    set(gca,'YDir','Normal')

    axis equal
    axis tight
    colormap(im(3),parula)
    caxis([780 2000])
    c = colorbar;
  xlabel('X(m)')
  ylabel('Z(m)')
   title ('Probabilistic Bead Structure multiple Classifications')
   text('Units','points','VerticalAlignment','bottom',...
    'HorizontalAlignment','center',...
    'Rotation',90,...
    'String','Bead Size \mum',...
    'Position',[350 50 0]);

% Final
im(4)=subplot(2,2,4);
imagesc(predProbability3(:,:,i))
    axis equal
    axis tight
   colormap(im(4),jet(256))
   caxis([780 1325])
   c = colorbar;
   title ('Final Probabilistic Bead Structure')
   text('Units','points','VerticalAlignment','bottom',...
    'HorizontalAlignment','center',...
    'Rotation',90,...
    'String','Bead Size \mum',...
    'Position',[350 50 0]);
end
toc