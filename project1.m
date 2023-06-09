clc
clear all
close all

% load the data
startdate = '01/01/1994';
enddate = '01/01/2022';
f = fred
YG = fetch(f,'CLVMNACSCAB1GQDE',startdate,enddate)
YJ = fetch(f,'JPNRGDPEXP',startdate,enddate)
yg = log(YG.Data(:,2));
yj = log(YJ.Data(:,2));
q = YG.Data(:,1);

T = size(yg,1);
U = size(yj,1);

% Hodrick-Prescott filter
lam = 1600;
A = zeros(T,T);

% unusual rows
A(1,1)= lam+1; A(1,2)= -2*lam; A(1,3)= lam;
A(2,1)= -2*lam; A(2,2)= 5*lam+1; A(2,3)= -4*lam; A(2,4)= lam;

A(T-1,T)= -2*lam; A(T-1,T-1)= 5*lam+1; A(T-1,T-2)= -4*lam; A(T-1,T-3)= lam;
A(T,T)= lam+1; A(T,T-1)= -2*lam; A(T,T-2)= lam;

% generic rows
for i=3:T-2
    A(i,i-2) = lam; A(i,i-1) = -4*lam; A(i,i) = 6*lam+1;
    A(i,i+1) = -4*lam; A(i,i+2) = lam;
end

tauJGDP = A\yg;
tauGGDP = A\yj;

% detrended GDP
ygtilde = yg-tauJGDP;
yjtilde = yj-tauGGDP;

% plot detrended GDP
dates = 1994:1/4:2022.1/4; zerovec = zeros(size(yg));
figure
title('Detrended log(real GDP) 1994Q1-2022Q1'); hold on
plot(q, ygtilde,'r', q, yjtilde,'b')
datetick('x', 'yyyy-qq')
legend('GERMANY', 'JAPAN', 'Location', 'best')

% compute sd(y), sd(c), rho(y), rho(c), corr(y,c) (from detrended series)
ygsd = std(ygtilde)*100;
yjsd = std(yjtilde)*100;
corryc = corrcoef(ygtilde(1:T),yjtilde(1:T)); corryc = corryc(1,2);

disp(['Standard deviation of detrended log real GERMANYGDP: ', num2str(ygsd),'.']); disp(' ')
disp(['Standard deviation of detrended log real JAPANGDP: ', num2str(yjsd),'.']); disp(' ')
disp(['Contemporaneous correlation between detrended log real JAPAN and GERMANY: ', num2str(corryc),'.']);