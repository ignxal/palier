# Feature Specification: Palier — Comparador de Hipotecas UVA

**Created**: 2025-05-20  
**Actualizado**: 2026-05-21

---

## User Scenarios & Testing *(mandatory)*

### User Story 1 — Comparar condiciones entre bancos (Priority: P1)

Un usuario que está evaluando tomar un crédito hipotecario UVA quiere ver de un vistazo las tasas, plazos y condiciones de todos los bancos argentinos para elegir el más conveniente para su perfil.

**Why this priority**: Es el núcleo del producto. Sin comparación de bancos no hay valor diferencial. Todo lo demás es complementario.

**Independent Test**: Un usuario puede abrir la página, leer la tabla, hacer clic en un banco para ir a su sitio oficial y tomar una decisión informada — sin necesitar ninguna otra funcionalidad.

**Acceptance Scenarios**:

1. **Scenario**: Usuario ve tabla completa
   - **Given** el usuario abre la página
   - **When** la tabla renderiza
   - **Then** ve los 14 bancos con tasa, plazo, financiación, monto máximo, primera cuota (ejemplo), C/I, ingreso mínimo, pre-cancelación, monotributista y destino

2. **Scenario**: Usuario identifica el banco más barato
   - **Given** la tabla está visible
   - **When** el usuario mira la columna "Tasa con sueldo"
   - **Then** los badges de semáforo indican visualmente verde (≤8,5%), amarillo (≤11%) y rojo (>11%)

3. **Scenario**: Usuario hace clic en el nombre de un banco
   - **Given** el banco aparece como pill-link en la tabla
   - **When** el usuario hace clic
   - **Then** se abre el sitio oficial del banco en una nueva pestaña

4. **Scenario**: Usuario ordena por cuota
   - **Given** la tabla está visible
   - **When** el usuario hace clic en el header "1ra cuota"
   - **Then** la tabla se reordena de menor a mayor cuota; un segundo clic invierte el orden

---

### User Story 2 — Filtrar bancos por perfil del solicitante (Priority: P2)

Un usuario monotributista o que busca financiación para refacción/construcción quiere ver solo los bancos que aceptan su situación.

**Why this priority**: Reduce el ruido para perfiles específicos. Sin filtros, el usuario debe leer toda la tabla y descartar bancos manualmente.

**Independent Test**: Un usuario activa el filtro "Acepta monotributistas", ve solo los bancos relevantes y puede ir directo a esos sitios.

**Acceptance Scenarios**:

1. **Scenario**: Filtro por monotributistas
   - **Given** la tabla muestra 14 bancos
   - **When** el usuario activa "✓ Acepta monotributistas"
   - **Then** la tabla filtra y muestra solo los bancos con `mono: true`; el contador actualiza ("X bancos")

2. **Scenario**: Combinar filtros
   - **Given** el usuario activa "Acepta monotributistas" y "Refacción / Ampliación"
   - **When** ambos filtros están activos
   - **Then** la tabla muestra solo bancos que cumplen ambas condiciones simultáneamente

3. **Scenario**: Limpiar filtros
   - **Given** hay al menos un filtro activo
   - **When** el usuario hace clic en "✕ Limpiar"
   - **Then** se desactivan todos los filtros y se vuelven a mostrar los 14 bancos

---

### User Story 3 — Entender el momento del mercado con el ratio UVA/USD (Priority: P2)

Un usuario con un crédito hipotecario UVA activo quiere saber si el ratio actual le conviene para precancelar o si es buen momento para sacar uno nuevo.

**Why this priority**: Es el diferenciador más fuerte del producto frente a comparadores simples. El ratio historiza el contexto económico argentino de forma accionable.

**Independent Test**: El usuario puede leer el banner de ratio, ver el gráfico histórico y entender qué acción tomar — sin necesitar las otras secciones.

**Acceptance Scenarios**:

1. **Scenario**: Ratio actual por encima del promedio
   - **Given** el ratio UVA/USD cargado es > 0,82
   - **When** se renderiza el banner
   - **Then** el banner es verde y dice "buen momento para tomar un crédito hipotecario UVA"

2. **Scenario**: Ratio actual por debajo del promedio
   - **Given** el ratio UVA/USD cargado es < 0,82
   - **When** se renderiza el banner
   - **Then** el banner es rojo y dice "momento oportuno para precancelar deuda UVA"

3. **Scenario**: Carga de datos en vivo
   - **Given** la página se sirve desde `localhost` (no `file://`)
   - **When** `fetchLiveData()` finaliza exitosamente
   - **Then** el strip superior muestra UVA, dólar oficial y ratio actualizados; el gráfico se reconstruye con datos reales del BCRA (mensualizados desde 2016)

4. **Scenario**: Fallback sin conexión
   - **Given** las APIs del BCRA no responden
   - **When** `fetchLiveData()` captura el error
   - **Then** la página muestra datos hardcodeados (fallback) y un aviso "⚠ sin conexión"

---

### User Story 4 — Modo oscuro / claro (Priority: P3)

El usuario puede cambiar el tema visual según su preferencia o el entorno (día/noche).

**Why this priority**: Feature de UX que no bloquea el caso de uso principal pero mejora la percepción de calidad del producto.

**Independent Test**: El usuario hace clic en el botón ☀️/🌙 del header y el tema cambia inmediatamente, incluyendo el gráfico.

**Acceptance Scenarios**:

1. **Scenario**: Toggle de tema
   - **Given** la página carga en modo claro (default)
   - **When** el usuario hace clic en el botón de tema
   - **Then** el fondo, colores y el gráfico cambian al modo oscuro; un segundo clic vuelve al modo claro

---

### Edge Cases

- ¿Qué pasa si el BCRA no responde en menos de 5 segundos? → El `catch` del `try/catch` de `fetchLiveData` activa el fallback con datos hardcodeados.
- ¿Qué pasa si se abren con `file://`? → Se muestra un banner con instrucciones para correr un servidor local.
- ¿Qué pasa si todos los filtros activos dejan 0 bancos? → La tabla muestra "0 bancos" y un tbody vacío — no hay mensaje de error explícito (mejora pendiente).
- ¿Qué pasa en pantallas muy angostas (< 375px)? → La tabla tiene scroll horizontal; las columnas pegadas (banco) se mantienen fijas.
- ¿Qué pasa si Chart.js falla al cargar del CDN? → El canvas queda en blanco; no hay error manejado — mejora pendiente.

---

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: El sistema DEBE mostrar los 14 bancos con sus condiciones actualizadas al abrir la página.
- **FR-002**: El sistema DEBE obtener el valor actual de UVA y el tipo de cambio oficial desde el BCRA y DolarAPI respectivamente.
- **FR-003**: El sistema DEBE calcular el ratio UVA/USD actual y compararlo con el promedio histórico (0,82).
- **FR-004**: El sistema DEBE mostrar el gráfico del ratio UVA/USD histórico desde 2016 con datos reales del BCRA.
- **FR-005**: El sistema DEBE funcionar con datos de fallback hardcodeados si las APIs no están disponibles.
- **FR-006**: Los usuarios DEBEN poder filtrar bancos por: aceptación de monotributistas, financiación de refacción/ampliación y línea de construcción.
- **FR-007**: Los usuarios DEBEN poder ordenar la tabla por: tasa con sueldo, tasa sin sueldo, plazo, financiación y primera cuota.
- **FR-008**: El sistema DEBE detectar si se abre desde `file://` y mostrar instrucciones para servidor local.
- **FR-009**: Los nombres de los bancos DEBEN enlazar al sitio oficial del banco en una nueva pestaña.
- **FR-010**: El sistema NO DEBE requerir un backend ni proceso de build para funcionar.

### Key Entities

- **Bank**: Entidad con condiciones de crédito (tasa, plazo, financiación, monto máximo, C/I, ingreso mínimo, pre-cancelación, destino, URL oficial).
- **RatioDataPoint**: Tupla `{mes: string, ratio: float}` que representa el promedio mensual del ratio UVA/USD.
- **Filter**: Estado activo/inactivo de los 3 filtros disponibles.
- **SortState**: Par `{columna: string, dirección: 'asc'|'desc'}` que determina el ordenamiento actual.

---

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: La tabla se renderiza con todos los bancos en menos de 200ms desde la apertura (datos hardcodeados).
- **SC-002**: Los datos en vivo del BCRA reemplazan el fallback en menos de 3 segundos en una conexión normal.
- **SC-003**: El gráfico histórico procesa y renderiza los ~3.000 puntos diarios del BCRA (mensualizados a ~110 puntos) sin degradar la UI.
- **SC-004**: El archivo `index.html` es completamente funcional sin conexión a Internet (fallback hardcodeado).
- **SC-005**: El tiempo de carga inicial es < 1 segundo en una conexión 4G argentina (archivo < 100KB, CDNs diferidos).
- **SC-006**: El sitio indexa correctamente en Google para términos como "comparar hipotecas UVA Argentina" (meta tags + Schema.org implementados).
