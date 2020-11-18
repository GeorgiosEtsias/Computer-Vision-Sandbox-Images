%----------------------G.Etsias January 21st 2019-------------------------%
%1)Script generates bead structure for given homogeneous or heterogeneous 
%aquifers and is executed after ClassificationData.m.
%2)The trainied ANN and the coresponrding prediction data need to be loaded
%3)Values of 'npts' and 'sizeia' values are determined in the execution of
%  ClassificationData.m
clc
%% Load the trained classification ANN
load ('ANNclassification'); %Loading the corresponding trained ANN
net2=ANNclassification;
inputs=DATAA(:,1:4); %Optimum training data feature combination
inputs=inputs';
outputs = net2(inputs);
outputs=outputs';
size2=size(outputs);

%% Modifying the classification ANNclassification results into single values 
% values of 780um, 1090um and 1325um bead sizes. 
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
prediction=reshape(BS,sizeia(1,1)-pixlim+1,sizeia(1,2),npts);

%% Plotting the generated heterogeneity fields
pixelsizem=0.0001054384;
for i=1:npts
    figure (i)
    imagesc([0 sizeia(1,2)]*pixelsizem,[0 sizeia(1,1)]*pixelsizem,...
        flipud(prediction(:,:,i)))
    set(gca,'YDir','Normal')
    axis equal
    axis tight
    xlabel('X(m)')
    ylabel('Y(m)')
    colormap(jet(256))
   caxis([780 1325])
   text('Units','points','VerticalAlignment','bottom',...
    'HorizontalAlignment','center',...
    'Rotation',90,...
    'String','Bead Size (\mum)',...
    'Position',[352 50 0]);
end