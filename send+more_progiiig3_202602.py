import copy

class CriptoAritmCSP:
    def __init__(self, palabras, dominio):
        self.palabras = palabras
        # Obtener las 8 letras únicas: {'S', 'E', 'N', 'D', 'M', 'O', 'R', 'Y'}
        self.variables = sorted(list(set(c for c in palabras if c not in ('+', '='))))
        self.dominio = dominio
        self.VarDom = {k: dominio.copy() for k in self.variables}
        self.Constraints = []
        self.nodos_explorados = 0  # Contador para medir eficiencia de la heurística

    def copy(self):
        """Realiza una copia profunda de la instancia actual para explorar ramas sin dañar el estado anterior."""
        return copy.deepcopy(self)

    def setConstraint(self, constraint):
        if constraint not in self.Constraints:
            self.Constraints.append(constraint)

    # --- RESTRICCIONES DE DOMINIO Y CONSISTENCIA ---

    def NoEsCero(self, variables):
        """Restricción unaria: Las letras iniciales (S y M) no pueden valer 0."""
        cambio = False
        for var in variables:
            if 0 in self.VarDom[var]:
                self.VarDom[var].remove(0)
                cambio = True
        return cambio

    def IgualA_Valor(self, variables, valor):
        """Fija el dominio de una variable a un valor específico deducido por lógica."""
        cambio = False
        for var in variables:
            if self.VarDom[var] != {valor}:
                self.VarDom[var] = {valor}
                cambio = True
        return cambio

    def MenorQue_PorValor(self, variables, valor):
        """Elimina valores mayores o iguales a 'valor'."""
        cambio = False
        for var in variables:
            old_dom = self.VarDom[var].copy()
            self.VarDom[var].difference_update(set(range(valor, 10)))
            if old_dom != self.VarDom[var]:
                cambio = True
        return cambio

    def MayorQue_PorValor(self, variables, valor):
        """Elimina valores menores o iguales a 'valor'."""
        cambio = False
        for var in variables:
            old_dom = self.VarDom[var].copy()
            self.VarDom[var].difference_update(set(range(valor + 1)))
            if old_dom != self.VarDom[var]:
                cambio = True
        return cambio

    def MenorQue_Variables(self, variables):
        """Consistencia de arco (2-consistencia): garantiza que var1 < var2."""
        cambio = False
        var1, var2 = variables[0], variables[1]
        if not self.VarDom[var1] or not self.VarDom[var2]:
            return False

        min_var1 = min(self.VarDom[var1])
        max_var2 = max(self.VarDom[var2])

        # Para todo x en var1 debe existir y en var2 tal que x < y (x < max(var2))
        old_dom1 = self.VarDom[var1].copy()
        self.VarDom[var1] = {x for x in self.VarDom[var1] if x < max_var2}

        # Para todo y en var2 debe existir x en var1 tal que x < y (y > min(var1))
        old_dom2 = self.VarDom[var2].copy()
        self.VarDom[var2] = {y for y in self.VarDom[var2] if y > min_var1}

        if old_dom1 != self.VarDom[var1] or old_dom2 != self.VarDom[var2]:
            cambio = True
        return cambio

    def TodosDiferentes(self, variables):
        """
        Restricción global (AllDifferent): Si una variable ya tiene un único valor asignado
        (dominio de tamaño 1), se elimina ese dígito del dominio de todas las demás variables.
        """
        cambio = False
        valores_fijos = {list(self.VarDom[v])[0] for v in variables if len(self.VarDom[v]) == 1}
        
        for var in variables:
            if len(self.VarDom[var]) > 1:
                old_dom = self.VarDom[var].copy()
                self.VarDom[var].difference_update(valores_fijos)
                if old_dom != self.VarDom[var]:
                    cambio = True
        return cambio

    def ConsitenciaGlobal(self):
        """
        Propaga todas las restricciones en ciclo (punto fijo) hasta que ningún dominio
        vuelva a reducirse, manteniendo la k-consistencia del CSP.
        """
        while True:
            cambio = False
            for restriction in self.Constraints:
                func_name = restriction[0]
                parametros = restriction[1:]
                if hasattr(self, func_name):
                    func = getattr(self, func_name)
                    cambio_actual = func(*parametros)
                    cambio = cambio or cambio_actual
            if not cambio:
                break

    # --- VALIDACIONES DEL EJERCICIO ---

    def es_solucion_completa(self):
        """Verifica si todas las variables tienen exactamente un valor asignado."""
        return all(len(self.VarDom[v]) == 1 for v in self.variables)

    def es_inconsistente(self):
        """Verifica si alguna variable se quedó sin valores posibles (dominio vacío)."""
        return any(len(self.VarDom[v]) == 0 for v in self.variables)

    def validar_ecuacion(self, estado):
        """Valida que los dígitos sean todos distintos y que SEND + MORE == MONEY."""
        if len(set(estado.values())) != len(estado):
            return False

        send = estado["S"]*1000 + estado["E"]*100 + estado["N"]*10 + estado["D"]
        more = estado["M"]*1000 + estado["O"]*100 + estado["R"]*10 + estado["E"]
        money = estado["M"]*10000 + estado["O"]*1000 + estado["N"]*100 + estado["E"]*10 + estado["Y"]

        return (send + more) == money

    # --- HEURÍSTICA Y BÚSQUEDA POR BACKTRACKING ---

    def seleccionar_variable_MRV(self):
        """
        Heurística MRV (Minimum Remaining Values / Valores Mínimos Restantes):
        Escoge la variable sin asignar (len > 1) que tenga la menor cantidad de valores
        disponibles en su dominio. Esto detecta fallos temprano y poda el árbol de búsqueda.
        """
        variables_no_asignadas = [v for v in self.variables if len(self.VarDom[v]) > 1]
        return min(variables_no_asignadas, key=lambda v: len(self.VarDom[v]))

    def backtracking(self):
        """Algoritmo de Backtracking con propagación de restricciones y heurística MRV."""
        self.nodos_explorados += 1

        # 1. Propagar consistencia en el estado actual
        self.ConsitenciaGlobal()

        # 2. Podar rama si alguna variable quedó sin valores posibles
        if self.es_inconsistente():
            return None, self.nodos_explorados

        # 3. Si todas las variables tienen un único valor, validar la suma SEND + MORE = MONEY
        if self.es_solucion_completa():
            valores_finales = {k: list(v)[0] for k, v in self.VarDom.items()}
            if self.validar_ecuacion(valores_finales):
                return valores_finales, self.nodos_explorados
            return None, self.nodos_explorados

        # 4. Seleccionar la siguiente variable usando la heurística MRV
        var_elegida = self.seleccionar_variable_MRV()

        # 5. Probar cada valor posible del dominio de la variable elegida
        for valor in sorted(list(self.VarDom[var_elegida])):
            nuevo_estado = self.copy()
            nuevo_estado.VarDom[var_elegida] = {valor}

            solucion, nodos_hijo = nuevo_estado.backtracking()
            self.nodos_explorados = nodos_hijo  # Acumular total de estados visitados

            if solucion is not None:
                return solucion, self.nodos_explorados

        return None, self.nodos_explorados


# ==============================================================================
# EJECUCIÓN Y MODELADO DEL PROBLEMA SEND + MORE = MONEY
# ==============================================================================
if __name__ == "__main__":
    problema = CriptoAritmCSP("SEND+MORE=MONEY", set(range(10)))

    # 1. Restricciones coherentes con la criptoaritmética:
    # Ningún número empieza por 0
    problema.setConstraint(("NoEsCero", ['S', 'M']))
    
    # Por acarreo de la suma de 4 dígitos (SEND + MORE = MONEY), M solo puede ser 1
    problema.setConstraint(("MenorQue_PorValor", ['M'], 2))
    
    # Como M = 1 y hay acarreo hacia las decenas de mil, S + 1 (+ posible acarreo) >= 10, entonces S > 7 (8 o 9)
    problema.setConstraint(("MayorQue_PorValor", ['S'], 7))
    
    # En la columna de las unidades: D + E = Y (o 10 + Y). Como E != 0, D no puede ser 0 si no hay acarreo,
    # y por la relación entre E y N (E + 1 = N cuando hay acarreo en centenas), E < N:
    problema.setConstraint(("MenorQue_Variables", ['E', 'N']))

    # Restricción global: Todas las 8 letras deben tener dígitos diferentes
    problema.setConstraint(("TodosDiferentes", problema.variables))

    print("Dominios iniciales antes de consistencia:", problema.VarDom)
    problema.ConsitenciaGlobal()
    print("Dominios reducidos tras Consistencia Global:", problema.VarDom)

    print("\nIniciando búsqueda por Backtracking con heurística MRV...")
    solucion, total_nodos = problema.backtracking()

    if solucion:
        print("\n¡Solución encontrada!")
        print("Asignación letra -> dígito:", solucion)
        send = solucion["S"]*1000 + solucion["E"]*100 + solucion["N"]*10 + solucion["D"]
        more = solucion["M"]*1000 + solucion["O"]*100 + solucion["R"]*10 + solucion["E"]
        money = solucion["M"]*10000 + solucion["O"]*1000 + solucion["N"]*100 + solucion["E"]*10 + solucion["Y"]
        print(f"Verificación: {send} + {more} = {money}")
        print(f"Nodos/estados explorados en el árbol de búsqueda: {total_nodos}")
    else:
        print("No se encontró solución.")