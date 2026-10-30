% PROGRAMACIÓN III - ACTIVIDAD 03: LISTAS EN PROLOG
% Estudiante: Lucas Ceron

% ==============================================================================
% PARTE 1: FAMILIA SIMPSON (UTILIZANDO ESTRUCTURAS Y LISTAS)


%   Base de Conocimiento con Estructuras 
% persona(Nombre, Genero)
persona(homero, masculino).
persona(marge, femenino).
persona(bart, masculino).
persona(lisa, femenino).
persona(maggie, femenino).
persona(abraham, masculino).
persona(mona, femenino).
persona(clancy, masculino).
persona(jacqueline, femenino).
persona(herbert, masculino).
persona(patty, femenino).
persona(selma, femenino).
persona(ling, femenino).

% matrimonio(Esposo, Esposa)
matrimonio(abraham, mona).
matrimonio(clancy, jacqueline).
matrimonio(homero, marge).

% estructura de familia: familia(Padres, Hijos)
% Padres = padres(Padre, Madre)
% Hijos = Lista de hijos
familia(padres(abraham, mona), [homero, herbert]).
familia(padres(clancy, jacqueline), [marge, patty, selma]).
familia(padres(homero, marge), [bart, lisa, maggie]).
familia(padres(ninguno, selma), [ling]).

% Padre / Madre
padre(P, Hijo) :-
    familia(padres(P, _), Hijos),
    member(Hijo, Hijos).

madre(M, Hijo) :-
    familia(padres(_, M), Hijos),
    member(Hijo, Hijos).

% Hermano de (utilizando la lista de hijos)
hermano_de(X, Y) :-
    familia(_, Hijos),
    member(X, Hijos),
    member(Y, Hijos),
    X \== Y.

% Abuelo / Abuela
abuelo(A, Nieto) :-
    persona(A, masculino),
    (padre(P, Nieto) ; madre(P, Nieto)),
    padre(A, P).

abuela(A, Nieto) :-
    persona(A, femenino),
    (padre(P, Nieto) ; madre(P, Nieto)),
    madre(A, P).

% Tía
tia(T, Sobrino) :-
    persona(T, femenino),
    (padre(P, Sobrino) ; madre(P, Sobrino)),
    hermano_de(T, P).

% Primo
primo(X, Y) :-
    (padre(P1, X) ; madre(P1, X)),
    (padre(P2, Y) ; madre(P2, Y)),
    hermano_de(P1, P2),
    X \== Y.


% ==============================================================================
% PARTE 2: CIUDADES DE CANADÁ (GRAFO CON ESTRUCTURAS Y BÚSQUEDA CON LISTAS)

% --- Base de Conocimiento de Aristas usando Estructuras ---
% ruta_dirigida(Origen, Destino, Costo)
arista(ruta_dirigida(vancouver, edmonton, 16)).
arista(ruta_dirigida(vancouver, calgary, 13)).
arista(ruta_dirigida(edmonton, saskatoon, 12)).
arista(ruta_dirigida(calgary, edmonton, 4)).
arista(ruta_dirigida(calgary, regina, 14)).
arista(ruta_dirigida(saskatoon, calgary, 9)).
arista(ruta_dirigida(saskatoon, winnipeg, 20)).
arista(ruta_dirigida(regina, saskatoon, 7)).
arista(ruta_dirigida(regina, winnipeg, 4)).

% Predicado auxiliar para consultar conexiones
conexion(Origen, Destino, Costo) :-
    arista(ruta_dirigida(Origen, Destino, Costo)).

% --- Regla 1: Determinar si un nodo tiene aristas de salida 
tiene_aristas(Nodo) :-
    conexion(Nodo, _, _).

% --- Regla 2: Costo de ir de X a Z pasando obligatoriamente por Y 
costo_pasando_por(X, Y, Z, CostoTotal) :-
    conexion(X, Y, C1),
    conexion(Y, Z, C2),
    CostoTotal is C1 + C2.

% --- Regla 3: Camino entre X y Z reteniendo la Lista del Camino 
camino(X, Z, Camino) :-
    camino_aux(X, Z, [X], CaminoReversa),
    reverse(CaminoReversa, Camino).

camino_aux(X, Z, Visitados, [Z|Visitados]) :-
    conexion(X, Z, _).

camino_aux(X, Z, Visitados, CaminoFinal) :-
    conexion(X, Y, _),
    Y \== Z,
    \+ member(Y, Visitados),
    camino_aux(Y, Z, [Y|Visitados], CaminoFinal).