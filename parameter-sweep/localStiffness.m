function k = localStiffness(Am,E,Lm,t)
%LOCALSTIFFNESS
%    K = LOCALSTIFFNESS(AM,E,LM,T)

%    This function was generated by the Symbolic Math Toolbox version 6.0.
%    26-Apr-2014 22:13:15

t2 = cos(t);
t3 = 1.0./Lm;
t4 = t2.^2;
t5 = Am.*E.*t3.*t4;
t6 = sin(t);
t7 = Am.*E.*t2.*t3.*t6;
t8 = t6.^2;
t9 = Am.*E.*t3.*t8;
k = reshape([t5,t7,-t5,-t7,t7,t9,-t7,-t9,-t5,-t7,t5,t7,-t7,-t9,t7,t9],[4, 4]);
