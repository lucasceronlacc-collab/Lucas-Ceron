% PROGRAMACIÓN III - ACTIVIDAD 02: BACKTRACKING Y RESOLUCIÓN SLD
% Estudiante: Lucas Ceron
 
% PARTE 1: GRAFO DIRIGIDO - CIUDADES DE CANADÁ
% Nodos: Vancouver(s), Edmonton(v1), Calgary(v2), Saskatoon(v3), Regina(v4), Winnipeg(t)

% --- Base de Conocimiento: Aristas Dirigidas y Costos ---
% conexion(Origen, Destino, Costo)
conexion(vancouver, edmonton, 16).
conexion(vancouver, calgary, 13).
conexion(edmonton, saskatoon, 12).
conexion(calgary, edmonton, 4).
conexion(calgary, regina, 14).
conexion(saskatoon, calgary, 9).
conexion(saskatoon, winnipeg, 20).
conexion(regina, saskatoon, 7).
conexion(regina, winnipeg, 4).

%  Regla 1: Determinar si un nodo tiene aristas de salida 
tiene_aristas(Nodo) :-
    conexion(Nodo, _, _).

% --- Regla 2: Costo para ir de X a Z pasando obligatoriamente por Y ---
costo_pasando_por(X, Y, Z, CostoTotal) :-
    conexion(X, Y, Costo1),
    conexion(Y, Z, Costo2),
    CostoTotal is Costo1 + Costo2.

%  Regla 3: Verificar si es posible viajar de un nodo X a un nodo Z 
% (Aplica Backtracking recursivo evitando ciclos mediante una lista de visitados)
camino(X, Z) :- 
    camino_aux(X, Z, [X]).
camino_aux(X, Z, _) :- 
    conexion(X, Z, _).
camino_aux(X, Z, Visitados) :- 
    conexion(X, Y, _),
    Y \== Z,
    \+ member(Y, Visitados),
    camino_aux(Y, Z, [Y|Visitados]).


% ==============================================================================
% PARTE 2: GRAFO NO DIRIGIDO - RUTAS DE ESPAÑA
% ==============================================================================

% --- Base de Conocimiento: Conexiones de Carretera (Simétricas) ---
distancia_directa(coruna, vigo, 171).
distancia_directa(coruna, valladolid, 455).
distancia_directa(vigo, valladolid, 356).
distancia_directa(oviedo, bilbao, 304).
distancia_directa(bilbao, valladolid, 280).
distancia_directa(bilbao, madrid, 395).
distancia_directa(bilbao, zaragoza, 324).
distancia_directa(valladolid, madrid, 193).
distancia_directa(madrid, zaragoza, 325).
distancia_directa(madrid, badajoz, 403).
distancia_directa(madrid, jaen, 335).
distancia_directa(madrid, albacete, 251).
distancia_directa(zaragoza, barcelona, 296).
distancia_directa(gerona, barcelona, 100).
distancia_directa(barcelona, valencia, 349).
distancia_directa(albacete, valencia, 191).
distancia_directa(albacete, murcia, 150).
distancia_directa(valencia, murcia, 241).
distancia_directa(jaen, sevilla, 242).
distancia_directa(jaen, granada, 99).
distancia_directa(sevilla, cadiz, 125).
distancia_distancia(sevilla, granada, 256). % sevilla a granada
distancia_directa(sevilla, granada, 256).
distancia_directa(granada, murcia, 278).

% --- Regla para Bidireccionalidad (Grafo No Dirigido) ---
carretera(X, Y, D) :- distancia_directa(X, Y, D).
carretera(X, Y, D) :- distancia_directa(Y, X, D).

% --- Búsqueda de Camino con Distancia Total Acumulada ---
ruta(Origen, Destino, Ruta, DistanciaTotal) :-
    ruta_aux(Origen, Destino, [Origen], RutaReversa, DistanciaTotal),
    reverse(RutaReversa, Ruta).

ruta_aux(X, X, Visitados, Visitados, 0).
ruta_aux(X, Z, Visitados, RutaFinal, DistanciaTotal) :-
    carretera(X, Y, D1),
    \+ member(Y, Visitados),
    ruta_aux(Y, Z, [Y|Visitados], RutaFinal, D2),
    DistanciaTotal is D1 + D2.