clc
clear all
TP=0;
FN=0;
TN=0;
FP=0;
recall=0;

[num,txt,raw9]=xlsread('test3.xls');%读取测试数据
raw13=raw9;
test_data=raw13;
test_label=raw13(:,end);
test_data(:,end)=[];
test_data(:,40:end)=[];%第一个问题删除后半部分数据,不带用药
% test_data(:,29:35)=[];
%  test_data(:,end-10:end-4)=[];
% test_data(:,29:35)=[];%删除前半部分数据
% test_label=num2cell(ones(size(test_data,1),1));

for index=1:numel(test_label)
    test_label{index}=num2str(test_label{index});
end


for index1=1:size(test_data,1)
    for index2=1:size(test_data,2)
%         if ismember(index2,[2,16,17,32:45])~=1%此行针对原始问题和欠采样
           if ismember(index2,[2,3,15,16,17])~=1%此行针对原始问题和欠采样
%                if ismember(index2,[37,38,39])~=1%此行针对原始问题和欠采样
%           if ismember(index2,[29:45])~=1%此行针对原始问题和欠采样
%                if ismember(index2,[29,30,31])~=1%此行针对原始问题和欠采样
%                 if ismember(index2,[29:31])~=1%此行针对原始问题和欠采样
%             if ismember(index2,[40,41,42])~=1%慈航针对过采样
%          if ismember(index2,[26:35])~=1
            test_data{index1,index2}=num2str(test_data{index1,index2});
        end
    end
end

%去掉手术到本次随访的时间
% train_data(:,end)=[];
% test_data(:,end)=[];



[colnum,coltxt,colnames]=xlsread('clonames.xls');
%clonames2是42列，2天后半段
%colnames5是35列，一天后半段
%colnames5是49列，三天后半段
% colnames(24:end)=[];%删除后半部分属性名，不带用药
%colnames(1:28)=[];%删除前半部分属性名
test_data=cell2table(test_data,'VariableNames', colnames);

load UMDeath.mat
[Predict_label,Scores] = predict(Factor, test_data);
correct=0;
for index=1:numel(test_label)
    if isequal(test_label{index},Predict_label{index})==1
        correct=correct+1;
    end
end
accuracy=correct/numel(test_label);
confusionmatrix=zeros(2);
for index=1:numel(Predict_label)
   confusionmatrix(str2num(test_label{index})+1,str2num(Predict_label{index})+1)=confusionmatrix(str2num(test_label{index})+1,str2num(Predict_label{index})+1)+1;
end
test_label=cell2mat(test_label);
test_label=str2num(test_label);
number1=numel(find(test_label==1));%阳性样本数
number2=numel(test_label)-number1;
predict_label=cell2mat(Predict_label);
predict_label=str2num(predict_label);
for index1=1:number1+number2
    if predict_label(index1)==1 & test_label(index1)==1
        TP=TP+1;
    end
    if predict_label(index1)==0 & test_label(index1)==0
         TN=TN+1;
     end
end

% for index1=1:number2
%     if predict_label(index1+number1)==2 & test_label(index1+number1)==2
%         TN=TN+1;
%     end
% end
FP=number2-TN;
        P=number1;
        N=number2;
FN=number1-TP;
Accuracy=(TP+TN)/(P+N);
Sensitivity=TP/P;
FNR=1-Sensitivity;
Specificity=TN/N;
FPR=1-Specificity;
recall= 1 - FN/P;
ROC=[];%画ROC曲线的存储矩阵
PR=[];%画PR曲线的存储矩阵
largevalues=[];
largevalues=Scores(:,2);%属于正例的概率
templabel=[];


    %组合矩阵
    comprehensivearray=[test_label largevalues];
    
     %排序
    for index4=1:size(comprehensivearray,1)
        for index5=index4+1:size(comprehensivearray,1)
            if comprehensivearray(index4,2)<comprehensivearray(index5,2)
                %交换
                temp=comprehensivearray(index4,:);
                comprehensivearray(index4,:)=comprehensivearray(index5,:);
                comprehensivearray(index5,:)=temp;
            end
        end
    end
   for index=1:size(comprehensivearray,1)
    benchmark=comprehensivearray(index,2);
    for index1=1:size(comprehensivearray,1)
        if comprehensivearray(index1,2)>=benchmark
           comprehensivearray(index1,3)=1;
        else
           comprehensivearray(index1,3)=0;
        end
    end

        FP1=0;
        TP1=0;
        FN1=0;
        for index2=1:size(comprehensivearray,1)
            if comprehensivearray(index2,1)==0 & comprehensivearray(index2,3)==1
                FP1=FP1+1;
            end
        end
        for index3=1:size(comprehensivearray,1)
            if comprehensivearray(index3,1)==1 & comprehensivearray(index3,3)==1
                TP1=TP1+1;
            end
        end
        for index3=1:size(comprehensivearray,1)
            if comprehensivearray(index3,1)==1 & comprehensivearray(index3,3)==0
                FN1=FN1+1;
            end
        end
  ROC(1,index)=FP1/N;%FPR
  ROC(2,index)=TP1/P; %FPR
  PR(2,index)=TP1/(FP1+TP1);%PRECISION
  PR(1,index)=TP1/(TP1+FN1);%RECALL
   end 
   
%   FP=ROC(1,:)*N;
%   TP=ROC(2,:)*P;
%   TN2=N-FP;
%   FN2=P-TP;
%   precision=TP./(TP+FP);
%   TPR=TP./(TP+FN);
%   recall=TPR;
% FPR=FP./(TN+FP);
% PR(1,:)=recall; PR(2,:)=precision;
%plot(PR(1,:),PR(2,:),'r-');
 plot(ROC(1,:),ROC(2,:),'-r');
%  save('Factor3.mat','Factor','-v7.3')