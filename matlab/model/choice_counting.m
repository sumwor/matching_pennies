function [left, right, leftR, rightR]=choice_counting(dyncount,dyncountR, N, choiceHistory, rewardHistory)

%%N: number of previous trials used, 1:5

%%---get the index needed when updating dynamic counting of left
        %%and right choices
% IndNeed=[0, 4, 8, 12, 16, 20, 24, 28];
% Ind1=[0, 4, 8, 12, 16, 20, 24, 28];
% for f =1:8
%     Ind1(f)=Ind1(f)+64;
% end
% IndNeed=[IndNeed,Ind1];
% temp=zeros(1,16);
% for f =1:16
%     temp(f)=IndNeed(f)+128;
% end
% IndNeed=[IndNeed,temp];
% temp2=zeros(1,32);
% for f =1:32
%     temp2(f)=IndNeed(f)+256;
% end
IndNeed=[0,4,8,12,16,20,24,28,64, 68, 72 ,76,80,84,88,92,128,132,136,140,144,148,152,156,192,196,200,204,208,212,216,220,256,260,264,268,272,276,280,284,320,324 ,328,332,336,340,344 ,348, 384,388, 392, 396,400, 404,408,412, 448,452,456, 460, 464 ,468 , 472 ,476];

%%count
if N==1
     left=sum(choiceHistory==2);
     right=sum(choiceHistory==3);
     leftR=0;
     rightR=0;
else
     searchSeqR=rewardHistory(end-N+2:end);
     for x=1:4-N+1
        searchSeqR=[searchSeqR,0];
     end
     searchSeqR=[searchSeqR,choiceHistory(end-N+2:end)-2,0];
     baseIndR=bin2dec(num2str(searchSeqR))+1;
     searchSeq=[choiceHistory(end-N+2:end),2];
     baseInd=bin2dec(num2str(searchSeq-2))+1;
     if N==5
     	left=dyncount(baseInd);
        right=dyncount(baseInd+1);
     	leftR=dyncountR(baseIndR);
     	rightR=dyncountR(baseIndR+1);
	 elseif N==4
     	left=dyncount(baseInd)+dyncount(baseInd+16);
        right=dyncount(baseInd+1)+dyncount(baseInd+17);
     	leftR=dyncountR(baseIndR)+dyncountR(baseIndR+16)+dyncountR(baseIndR+256)+dyncountR(baseIndR+272);
     	rightR=dyncountR(baseIndR+1)+dyncountR(baseIndR+17)+dyncountR(baseIndR+257)+dyncountR(baseIndR+273);
     elseif N==3
     	left=dyncount(baseInd)+dyncount(baseInd+16)+dyncount(baseInd+8)+dyncount(baseInd+24);
     	right=dyncount(baseInd+17)+dyncount(baseInd+1)+dyncount(baseInd+9)+dyncount(baseInd+25);
     	leftR=dyncountR(baseIndR)+dyncountR(baseIndR+8)+dyncountR(baseIndR+16)+dyncountR(baseIndR+24)+dyncountR(baseIndR+128)+dyncountR(baseIndR+136)+dyncountR(baseIndR+144)+dyncountR(baseIndR+152)+dyncountR(baseIndR+256)+dyncountR(baseIndR+264)+dyncountR(baseIndR+272)+dyncountR(baseIndR+280)+dyncountR(baseIndR+384)+dyncountR(baseIndR+392)+dyncountR(baseIndR+400)+dyncountR(baseIndR+408);
     	rightR=dyncountR(baseIndR+1)+dyncountR(baseIndR+9)+dyncountR(baseIndR+17)+dyncountR(baseIndR+25)+dyncountR(baseIndR+129)+dyncountR(baseIndR+137)+dyncountR(baseIndR+145)+dyncountR(baseIndR+153)+dyncountR(baseIndR+257)+dyncountR(baseIndR+265)+dyncountR(baseIndR+273)+dyncountR(baseIndR+281)+dyncountR(baseIndR+385)+dyncountR(baseIndR+393)+dyncountR(baseIndR+401)+dyncountR(baseIndR+409);
     elseif N==2
     	left=dyncount(baseInd)+dyncount(baseInd+4)+dyncount(baseInd+8)+dyncount(baseInd+12)+dyncount(baseInd+16)+dyncount(baseInd+20)+dyncount(baseInd+24)+dyncount(baseInd+28);
     	right=dyncount(baseInd+1)+dyncount(baseInd+5)+dyncount(baseInd+9)+dyncount(baseInd+13)+dyncount(baseInd+17)+dyncount(baseInd+21)+dyncount(baseInd+25)+dyncount(baseInd+29);
     	leftR=0;rightR=0;
        for x=1:length(IndNeed)
        	leftR=leftR+dyncountR(baseIndR+IndNeed(x));
        	rightR=rightR+dyncountR(baseIndR+IndNeed(x)+1);
        end
        
     end
     
     
end