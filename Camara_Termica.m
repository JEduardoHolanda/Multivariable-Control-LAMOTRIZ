clear all
close all
clc

% Definição do espaço de estados das duas malhas juntas
h11 = tf([0.3145],[1.753 1]);
h12 = tf([-0.3483],[11.29 1]);
h21 = tf([-0.01649],[0.3065 1]);
h22 = tf([0.2356],[26.07 1]);

H11 = cell2mat(h11.den); 
H12 = cell2mat(h12.den);

A1 = conv(H11,H12);
A1 = A1'/(A1(1));

H21 = cell2mat(h21.den); 
H22 = cell2mat(h22.den);

A2 = conv(H21,H22);
A2 = A2'/(A2(1));

H = [h11 h12; h21 h22];

Hss = ss(H);

Ha = Hss.A;
Hb = Hss.B; 
Hc = Hss.C;
Hd = Hss.D;

zero2x2 = [0 0; 0 0];
zero4x2 = [0 0; 0 0; 0 0; 0 0];
identidade1 = [1 0 0 0; 0 1 0 0];
identidade2 = [0 0 1 0; 0 0 0 1; 0 0 0 0; 0 0 0 0];
Alinha = [zero2x2 -Hc;zero4x2 Ha];
Blinha = [identidade1 zero2x2; identidade2 Hb];

%Qx=2.5e-1*eye(6);

%     Qx = [100   0         0          0           0       0;
%           0     1         0          0           0       0;
%           0     0         100        0           0       0;
%           0     0         0          120         0       0;
%           0     0         0          0           40      0;
%           0     0         0          0           0       30];

        Qx = 2.5*10^-1*[  1         0         0          0           0       0;
                          0         1         0          0           0       0;
                          0         0         10         0           0       0;
                          0         0         0          10          0       0;
                          0         0         0          0           3.5     0;
                          0         0         0          0           0       1.5];
Ru=eye(6);
Klinha = lqr(Alinha,Blinha,Qx,Ru);

% Matriz de feedback para as varíaveis controladas e as variáveis de
% integração

Kx = Klinha(1:4,1:4);
Ki = Klinha(5:6,5:6);

Kxlinha = [Kx(:,1), Kx(:,3), Kx(:,2), Kx(:,4)];
K1=Klinha(1,5);
K2=Klinha(3,5);
K3=Klinha(6,5);
K4=Klinha(6,6);

Kcurioso = [K1 K2 K3 K4];

n = size(A1,1);
alpha = 0.2;
T = [1 alpha];

for k=1:n-1
    T = conv(T,[1 alpha]);
end

E1 = 0;
E2 = 0;
for i=1:size(A1,1)
    E1 = [E1;T(i+1)-A1(i)];
end

for i=1:size(A2,1)
    E2 = [E2;T(i+1)-A2(i)];
end

sim('camara_termicaprofwilkley_editado_0527.slx');


%  out=ans;
%  
%  uk=out.controle.data;
%  yk=out.saida.data;
%  t=out.controle.time;
%  
%  subplot(2,1,1)
%  plot(t,uk)
%  title('Sinais de controle')
%  legend('temperatura','umidade')
%  grid on
%  subplot(2,1,2)
%  plot(t,yk)
%  title('Sinais de saída')
%  legend('temperatura','umidade')
%  grid on