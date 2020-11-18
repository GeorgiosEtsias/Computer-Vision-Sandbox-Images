%----------------------G.Etsias July 27th 2018----------------------------%
% 1) Generates prediction of SW concentration using a swallow ANN
% 2) Test datasets should have the exact same dimensions with the training
%    dataset the ANN was trained on
% 3) Script is executed after RegressionTestData.m
clc
load('ANNregression')% pretrained ANN
par=1; %set par=1 to calculate the pareto solution
%% Perfect C=0%
inputs=DATAC0;
inputs=inputs';
outputs = ANNregression(inputs);
garea=reshape(outputs,sizeia(1,1)-pixlim+1,sizeia(1,2),npts);
for k=1:npts
for i=1:sizeia(1)
    for j=1:sizeia(2)
        if garea(i,j,k)>=100
            garea(i,j,k)=100;
        end
        if garea(i,j,k)<=0
            garea(i,j,k)=0;
        end
    end
end
end
PredictionC0=garea;
clear garea output
%% Perfect C=100%
inputs=DATAC100;
inputs=inputs';
outputs = ANNregression(inputs);
garea=reshape(outputs,sizeia(1,1)-pixlim+1,sizeia(1,2),npts);
for k=1:npts
for i=1:sizeia(1)
    for j=1:sizeia(2)
        if garea(i,j,k)>=100
            garea(i,j,k)=100;
        end
        if garea(i,j,k)<=0
            garea(i,j,k)=0;
        end
    end
end
end
PredictionC100=garea;

%% Give the correct dimensions of predicted SW fields 
PredictionC0=PredictionC0(:,:,2:sizeia(3)+1);
PredictionC100=PredictionC100(:,:,2:sizeia(3)+1);
%% Pareto prediction combination
sizeia=size(PredictionC0);
pixelsizem=0.0001054384;
ALL=cat(4,PredictionC0,PredictionC100);
PredictionParetoLinAv2055=mean(ALL,4);
for k=1:sizeia(3)
    for i=1:sizeia(1)
       for j=1:sizeia(2)
            if PredictionC100(i,j,k)>=95
                PredictionParetoLinAv2055(i,j,k)=PredictionC100(i,j,k);
            elseif PredictionC0(i,j,k)<=5
                PredictionParetoLinAv2055(i,j,k)=PredictionC0(i,j,k);
            elseif PredictionC100(i,j,k)>=50
                   PredictionParetoLinAv2055(i,j,k)=((PredictionC100(i,j,k)/100)*PredictionC100(i,j,k))+...
                       ((1-(PredictionC100(i,j,k)/100))*PredictionC0(i,j,k));
            elseif PredictionC0(i,j,k)<=20
                PredictionParetoLinAv2055(i,j,k)= (((1-(40-PredictionC0(i,j,k))/40))*PredictionC100(i,j,k))+...
                       ((40-PredictionC0(i,j,k))/40*PredictionC0(i,j,k));
            end
        end
    end
end
%% Plotting final predicted SW concentration fields
for i=1:sizeia(3)
figure (i)
imagesc([0 sizeia(1,2)]*pixelsizem,[0 sizeia(1,1)]*pixelsizem,flipud(PredictionParetoLinAv2055(:,:,i)))
   set(gca,'YDir','Normal')
   axis equal
   axis tight
   colormap(jet(256))
   caxis([0 100])
   c = colorbar;
   xlabel('X(m)')
   ylabel('Z(m)')
   text('Units','points','VerticalAlignment','bottom',...
    'HorizontalAlignment','center',...
    'Rotation',90,...
    'String','SW concentration %',...
    'Position',[360 50 0]);
end

