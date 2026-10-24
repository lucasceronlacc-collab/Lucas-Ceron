
% FACULTAD DE INGENIERÍAS - PROGRAMACIÓN III
% ACTIVIDAD 01 - PROGRAMACIÓN LÓGICA EN PROLOG

% EJERCICIO 1: ÁRBOL GENEALÓGICO DE LOS SIMPSON


% HECHOS (Relaciones directas / 1 generación)

% Padres/Madres de la 1 Generación -> 2 Generación (Rama Simpson/Powell)
padre(abraham, herbert).
padre(abraham, homero).
madre(mona, homero).

% Padres/Madres de la 1 Generación -> 2 Generación (Rama Bouvier)
padre(clancy, marge).
padre(clancy, patty).
padre(clancy, selma).

madre(jacqueline, marge).
madre(jacqueline, patty).
madre(jacqueline, selma).

% Padres/Madres de la 2 Generación -> 3 Generación
padre(homero, bart).
padre(homero, lisa).
padre(homero, maggie).

madre(marge, bart).
madre(marge, lisa).
madre(marge, maggie).

madre(selma, ling).

% Sexo de los integrantes (para definir reglas de género)
hombre(abraham).
hombre(clancy).
hombre(herbert).
hombre(homero).
hombre(bart).

mujer(mona).
mujer(jacqueline).
mujer(marge).
mujer(patty).
mujer(selma).
mujer(lisa).
mujer(maggie).
mujer(ling).


% Definición general de progenitor
progenitor(X, Y) :- padre(X, Y).
progenitor(X, Y) :- madre(X, Y).

% Abuelo y Abuela
abuelo(X, Y) :- 
    hombre(X), 
    progenitor(X, Z), 
    progenitor(Z, Y).

abuela(X, Y) :- 
    mujer(X), 
    progenitor(X, Z), 
    progenitor(Z, Y).

% Hermanos (comparten progenitor y no son la misma persona)
hermano_de(X, Y) :- 
    progenitor(P, X), 
    progenitor(P, Y), 
    X \= Y.

% Tío y Tía
tio(X, Y) :- 
    hombre(X), 
    hermano_de(X, Z), 
    progenitor(Z, Y).

tia(X, Y) :- 
    mujer(X), 
    hermano_de(X, Z), 
    progenitor(Z, Y).

% Primo y Prima
primo(X, Y) :- 
    progenitor(P1, X), 
    progenitor(P2, Y), 
    hermano_de(P1, P2), 
    X \= Y.


% EJERCICIO 2: BASE DE CONOCIMIENTO SOBRE EL CORONEL WEST

% --- HECHOS ---
estadounidense(west).
enemigo(corea_del_sur, eeuu).
tiene(corea_del_sur, m1).
misil(m1).

% --- REGLAS ---
% Todo misil es un arma
arma(X) :- 
    misil(X).

% Si una nación es enemiga de EE.UU., se considera hostil
hostil(X) :- 
    enemigo(X, eeuu).

% Todos los misiles que tiene Corea del Sur se los vendió West
vendio(west, X, corea_del_sur) :- 
    misil(X), 
    tiene(corea_del_sur, X).

% Ley: Es criminal si un estadounidense vende armas a una nación hostil
criminal(X) :- 
    estadounidense(X), 
    arma(Y), 
    vendio(X, Y, Z), 
    hostil(Z).