clear all 
close all
clc

R = 3.33;
L = 4.56 * 10^(-3);
K = 0.0332;

b = 4.59 * 10^(-5);
J = 4.96 * 10^(-5);


%load dados2.mat
Ts = 0.01;

%teste = frest.PRBS('Amplitude',1,'Ts',6,'Order',1,'NumPeriods',10);

%Ts = 1.0; % 1a ordem
sim('ssc_house_heating_system_jess.slx')

length(y);

t = length(y);

% Seleciona dados eliminando regi�es com pouca correla��o (reg. perm.)
%y = y(1:end);
%u = u(1:end);
% remove componente do sinal de sa�d aque n�o tem correla��o com a entrada
% neste caso um n�vel constante dde valor igual a 2


% Dados para identifica��o (60% dos dados s�o util. p/ identificar)
yi = y(1:floor(length(y)*0.6));
ui = u(1:floor(length(y)*0.6));

% Dados para valida��o (40% dos dados s�o util. p/ validar)
yv = y(floor(length(y)*0.6)+1:end);
uv = u(floor(length(y)*0.6)+1:end);


% Defini��o da ordem do modelo
nb = 2;
na = 1;
d = 0;

% Identifica��o do modelo
N=length(yi);

t=[0:Ts:(N-1)*Ts];
subplot(1,2,1)
plot(t,yi,'r')
hold on;
plot(t,ui,'k--')
title('Dados para identifica��o');

ci=max(nb+d,na);

phi=zeros(N-ci,nb+na);

for i=ci+1:N 
    phi(i-ci,:) = [-(yi(i-1:-1:i-na))' ui(i-1-d:-1:i-nb-d)'];
end

if det(phi'*phi)==0
    error('A matriz phiT*phi � singular','A');
end

teta = inv(phi'*phi)*phi'*yi(ci+1:N);

% Valida��o do Modelo
N = length(yv);
ye = zeros(N,1);

for i=ci+1:N
    phi = [-(ye(i-1:-1:i-na))' uv(i-1-d:-1:i-nb-d)'];
    ye(i) = phi*teta;
end


% �ndice de desempenho, quanto mais pr�ximo de 100% melhor
id = max(1-(var(yv -ye))/(var(yv)))*100


t=[0:Ts:(N-1)*Ts];
subplot(1,2,2)
plot(t,yv,'r')
hold on;
plot(t,ye,'b')
plot(t,uv,'k--')
title('Valida��o do modelo');




