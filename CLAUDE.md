# Palier — CLAUDE.md

## Qué es este proyecto
Single-file web app (`index.html`) que compara créditos hipotecarios UVA en Argentina.
Sin backend, sin build step, sin dependencias de npm. Todo vive en `index.html`.

## Cómo correr localmente
```bash
python3 -m http.server 8080   # luego abrir http://localhost:8080
./serve.sh                    # alternativa con detección automática de runtime
```
**No abrir con `file://`** — CORS bloquea las APIs del BCRA.

## Arquitectura de index.html

```
<style>          CSS variables de tema + componentes (.glass, .tab-btn, .calc-field, etc.)
<header>         Logo · Stats strip (UVA, CCL, ratio) · Tab bar
<main>
  #panelComparador   Top 3 cards · Ratio banner · Filtros · Tabla · Gráfico ratio histórico
  #panelCalculadora  Inputs (valor USD, financiación, plazo) · Info box (capital, ingreso mín, UVAs)
                     Supuestos económicos (inflación, ajuste real) · Tabla 14 bancos · Gráfico proyección 24m
  #panelInfo         6 cards explicativos (UVA, crédito, fórmula, ratio, C/I, precancelación) · Glosario
<footer>
<script>
  DATA             banks[], FALLBACK_PTS, DOLLAR_CCL_MONTHLY
  GLOBALS          RATIO_ACTUAL, RATIO_PROMEDIO, DOLLAR_ACTUAL, UVA_ACTUAL, calcState, isDark
  TAB              switchTab(tab)
  SLIDER HELPERS   syncSlider, syncNumber, updateSliderFill, stepField, initSliders
  FORMULA          frenchFactor(tnaPct, plazoAnios), computeCuotaForBank(capitalARS, tna, plazo)
  CALC             recalcAll(), recalcDebounced(), renderCalcTable(), renderProyeccion()
  COMPARADOR       renderTop3(), renderTable(), renderBanner(), colSort(), toggleFilter()
  CHART            renderChart(data), setChartPeriod(p), monthlyToAnnual(monthly), getChartData()
  LIVE DATA        fetchLiveData(), fetchBCRAVariable(idVariable)
  INIT             renderBanner() → renderTop3() → renderTable() → updateSortIcons()
                   → renderChart() → initSliders() → fetchLiveData()
```

## APIs y fuentes de datos

| Dato | Fuente | Frecuencia |
|---|---|---|
| UVA actual + histórico | BCRA v4.0 variable 31 | Cada carga de página |
| CCL actual | DolarAPI `/dolares/contadoconliqui` | Cada carga de página |
| CCL histórico 2016-2026 | `DOLLAR_CCL_MONTHLY` hardcodeado (Bluelytics monthly avgs) | Estático |
| TC BNA reciente | BCRA v4.0 variable 4 (solo primera página) | Cada carga de página |

**Metodología del ratio histórico:**
- Meses en `DOLLAR_CCL_MONTHLY`: ratio = UVA_mensual / CCL_hardcodeado
- Meses recientes no cubiertos: ratio = UVA_mensual / TC_BNA_reciente (spread <2% post-cepo)
- Mes actual: ratio = UVA_live / CCL_live

**Nota cepo 2019-2023:** TC BNA oficial divergía fuertemente del CCL (spreads 80-158%).
`DOLLAR_CCL_MONTHLY` corrige esto — usar CCL real para esos períodos.

## Datos de bancos

El array `banks[]` es **manual**. Cuando un banco cambia condiciones, editar el objeto
correspondiente. Campos clave:

```javascript
{ name, url, color, textColor,
  tasa,           // TNA con acreditación de sueldo
  tasaSin,        // TNA sin sueldo (null si no aplica)
  plazo,          // máximo en años
  financiacion,   // % máximo del valor del inmueble
  cuota,          // FALLBACK hardcodeado — el valor dinámico lo calcula computeCuotaForBank()
  ci,             // relación cuota/ingreso máxima (%)
  mono,           // acepta monotributistas: true/false/null
  destino,        // array: ["1ra","2da","Refacción","Ampliación"]
  construccion    // boolean
}
```

## Convenciones de código

- Variables y funciones en español
- CSS con variables (`--accent`, `--fg`, etc.) — no hardcodear colores
- Tailwind CDN solo para utilidades de layout (grid, flex, padding, margin)
- Fuentes: IBM Plex Sans (body/headings) + IBM Plex Mono (labels, datos financieros)
- Dos instancias de Chart.js: `chartInstance` (ratio histórico) y `proyeccionChartInstance`
- Tema: `isDark` boolean global; `[data-theme="dark"]` en `<html>`
- Debounce en sliders (80ms) para no re-renderizar a 60fps durante drag

## No hacer

- ❌ Agregar dependencias de npm ni paso de build — es un HTML estático
- ❌ Separar en múltiples archivos — se sirve como archivo único
- ❌ Modificar `DOLLAR_CCL_MONTHLY` sin actualizar `FALLBACK_PTS` con valores consistentes
- ❌ Abrir con `file://` para testing — usar `python3 -m http.server 8080`
- ❌ Hardcodear colores inline si ya existe una variable CSS equivalente
