
:- use_module(library(lists)).

% Define los operadores logicos
:- op(1150,xfy,or). % Disjunction
:- op(1150,fx,neg). % Negation
:- op(1150,xfy,and). % Conjuction
:- op(1150,xfy,impl). % Implication
:- op(1150,xfy,iff). % Double Implication

% Elimina conjuncion, implicaciones y equivalencias para que 
% la formula solo tenga negaciones y disyunciones
% Hace uso de equivalencias logicas para eliminarlas
dnf(A,A) :- atom(A).
dnf(neg A,neg C) :- dnf(A,C).
dnf(A or B,C or D) :- dnf(A,C),dnf(B,D).
dnf(A and B,neg((neg C) or (neg D))) :- dnf(A,C),dnf(B,D).
dnf(A impl B,(neg C) or D) :- dnf(A,C),dnf(B,D).
dnf(A iff B,C) :- dnf((A impl B) and (B impl A),C).

% Aplica dnf a listas de formulas
% Solo toma la cabeza, le aplica dnf
% y se aplica recursivamente sobre la cola de la lista
dnfL([],[]).
dnfL([F|Fs],[G|Gs]) :- dnf(F,G),dnfL(Fs,Gs).

% Es verdadero si y solo si I y D, es decir D se deduce de I
sc(I,D) :- not(intersection(I,D,[])). % Hipotesis
sc([(neg F)|I],D) :- sc_aux(I,[F|D]). % negacion izquierda
sc(I,[(neg F)|D]) :- sc_aux([F|I],D). % negacion derecha
sc(I,[(F1 or F2)|D]) :- union([F1,F2],D,D1),sc_aux(I,D1). % disyucion derecha
sc([(F1 or F2)|I],D) :- sc_aux([F1|I],D),sc_aux([F2|I],D). % disyuncion izquierda

% Expresa que si D1 es el calculo de secuentes  de I1
% Eentonces esta relacion se conserva para cualquier permutacion
% de D1 e I1 (no depende del orden de los elementos en la lista)
sc_aux(I,D):-permutation(I,I1),permutation(D,D1),sc(I1,D1).

% Expresa que si la dnf de las formulas en I y D,
% provocan que sc de estas sea verdadero, entonces sc1 de I y D tambien lo es
% Es decir, aplica el calculo de secuentes a formulas con todos los conectivos
sc1(I,D) :- dnfL(I,I1),dnfL(D,D1),sc(I1,D1).