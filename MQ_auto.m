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

% Seleciona dados eliminando regiões com pouca correlação (reg. perm.)
%y = y(1:end);
%u = u(1:end);
% remove componente do sinal de saíd aque não tem correlação com a entrada
% neste caso um nível constante dde valor igual a 2


% Dados para identificação (60% dos dados são util. p/ identificar)
yi = y(1:floor(length(y)*0.6));
ui = u(1:floor(length(y)*0.6));

% Dados para validação (40% dos dados são util. p/ validar)
yv = y(floor(length(y)*0.6)+1:end);
uv = u(floor(length(y)*0.6)+1:end);


% Definição da ordem do modelo
nb = 2;
na = 1;
d = 0;

% Identificação do modelo
N=length(yi);

t=[0:Ts:(N-1)*Ts];
subplot(1,2,1)
plot(t,yi,'r')
hold on;
plot(t,ui,'k--')
title('Dados para identificação');

ci=max(nb+d,na);

phi=zeros(N-ci,nb+na);

for i=ci+1:N 
    phi(i-ci,:) = [-(yi(i-1:-1:i-na))' ui(i-1-d:-1:i-nb-d)'];
end

if det(phi'*phi)==0
    error('A matriz phiT*phi é singular','A');
end

teta = inv(phi'*phi)*phi'*yi(ci+1:N);

% Validação do Modelo
N = length(yv);
ye = zeros(N,1);

for i=ci+1:N
    phi = [-(ye(i-1:-1:i-na))' uv(i-1-d:-1:i-nb-d)'];
    ye(i) = phi*teta;
end


% Índice de desempenho, quanto mais próximo de 100% melhor
id = max(1-(var(yv -ye))/(var(yv)))*100


t=[0:Ts:(N-1)*Ts];
subplot(1,2,2)
plot(t,yv,'r')
hold on;
plot(t,ye,'b')
plot(t,uv,'k--')
title('Validação do modelo');




