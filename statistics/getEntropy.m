function dblH = getEntropy( input )
	%UNTITLED Summary of this function goes here
	%   Detailed explanation goes here
	
	%Uniform distribution, range 1-10
uni1=randi(10,1,10000);
edges=1:10;
p_uni1=histc(uni1,edges);
p_uni1=p_uni1/sum(p_uni1);
subplot(2,2,1),bar(edges,p_uni1);
h_uni1=-sum(p_uni1.*log2(p_uni1));
title(['H= ',num2str(h_uni1)]);
%Uniform distribution, range 1-100
uni2=randi(100,1,10000);
edges=1:100;
p_uni2=histc(uni2,edges);
p_uni2=p_uni2/sum(p_uni2);
subplot(2,2,2),bar(edges,p_uni2);
h_uni2=-sum(p_uni2.*log2(p_uni2));
title(['H= ',num2str(h_uni2)]);
%Normal distribution, range 1-10, mean 5, std 2
norm1=randn(1,10000)*2+5;
norm1=ceil(norm1(norm1>=0 & norm1<=10));
edges=1:10;
p_norm1=histc(norm1,edges);
p_norm1=p_norm1/sum(p_norm1);
subplot(2,2,3),bar(edges,p_norm1);
h_norm1=-sum(p_norm1.*log2(p_norm1));
title(['H= ',num2str(h_norm1)]);
%Normal distribution, range 1-10, mean 5, std 0.5
norm2=randn(1,10000)*0.5+5;
norm2=ceil(norm2(norm2>=0 & norm2<=10));
edges=1:10;
p_norm2=histc(norm2,edges);
p_norm2=p_norm2/sum(p_norm2);
subplot(2,2,4),bar(edges,p_norm2);
h_norm2=-nansum(p_norm2.*log2(p_norm2));
title(['H= ',num2str(h_norm2)]);

%% Bimodal distribution
mu = [5 -3]; Sigma = [.9 .4; .4 .3];
r = mvnrnd(mu, Sigma, 10000);
figure;
subplot(121);
plot(r(:,1),r(:,2),'.');
%Bin data
app=find(abs(r(:,1))<=10 & abs(r(:,2))<=10);
r=round(r(app,:));
hold on
plot(r(:,1),r(:,2),'.r');
%Compute histogram
edges{1}=0:10;
edges{2}=-10:0;
p_bimod=hist3(r,edges);
p_bimod=p_bimod./sum(sum(p_bimod));
subplot(122);
surfc(edges{1},edges{2},p_bimod);
title('P(x,y)');
%Compute p(x) and p(y) (marginal probabilities)
p_x=sum(p_bimod,2);
p_y=sum(p_bimod,1);
figure;
subplot(121);
bar(edges{1},p_x);
title('P(x)');
subplot(122);
bar(edges{2},p_y);
title('P(y)');
%Compute p(x|y) (conditional probability)
p_x_given_y=zeros(size(p_bimod));
for i=1:length(p_x)
for j=1:length(p_y)
p_x_given_y(i,j)=p_bimod(i,j)/p_y(j);
end
end
figure;
surfc(edges{1},edges{2},p_x_given_y);
title('P(x|y)');
%Entropies
H_xy=-nansum(nansum(p_bimod.*log2(p_bimod)));

%% Entropies
H_x=-nansum(p_x.*log2(p_x));
H_y=-nansum(p_y.*log2(p_y));
H_xy=-nansum(nansum(p_bimod.*log2(p_bimod)));
H_x_given_y=-nansum(nansum(p_bimod.*log2(p_x_given_y)));
I_xy=0;
for i=1:length(p_x)
for j=1:length(p_y)
app=p_bimod(i,j)*log2(p_bimod(i,j)/(p_x(i)*p_y(j)));
if~isnan(app)
I_xy=I_xy+app;
end
end
end
I_xy_bis=H_x-H_x_given_y;


%% Bin size
clear;
mu = [5 -3]; Sigma = [.9 .4; .4 .3];
r = mvnrnd(mu, Sigma, 10000);
%Bin data
app=find(abs(r(:,1))<=10 & abs(r(:,2))<=10);
r=r(app,:);
widths=.01:.01:1;
I_xy=zeros(size(widths));
H_x=zeros(size(widths));
H_x_given_y=zeros(size(widths));
for k=1:length(widths)
%Compute histogram
edges{1}=0:widths(k):10;
edges{2}=-10:widths(k):0;
p_bimod=hist3(r,edges);
p_bimod=p_bimod./sum(sum(p_bimod));
%Compute p(x) and p(y) (marginal probabilities)
p_x=sum(p_bimod,2);
p_y=sum(p_bimod,1);
%Compute p(x|y) (conditional probability)
p_x_given_y=zeros(size(p_bimod));
for i=1:length(p_x)
for j=1:length(p_y)
p_x_given_y(i,j)=p_bimod(i,j)/p_y(j);
end
end
%Entropies
H_x(k)=-nansum(p_x.*log2(p_x));
H_x_given_y(k)=-nansum(nansum(p_bimod.*log2(p_x_given_y)));
I_xy(k)=H_x(k)-H_x_given_y(k);
end
figure;
plot(widths,H_x,widths,H_x_given_y,widths,I_xy);
xlabel('Bin width');
legend('H(X)', 'H(X|Y)', 'I(X;Y)');


%Iunbiased(R,S)=I(R,S)-Ishuffled(R,S)=0.50-0.03=0.47 bits
end

