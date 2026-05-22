# 🏠 Palier

> Comparador de créditos hipotecarios UVA en Argentina — datos en tiempo real del BCRA.

[![Status](https://img.shields.io/badge/status-beta-yellow)](https://palier.ar)
[![Fuente](https://img.shields.io/badge/datos-BCRA%20%2B%20DolarAPI-blue)](https://api.bcra.gob.ar)
[![Tecnología](https://img.shields.io/badge/stack-HTML%20%2B%20Chart.js-lightgrey)](#tecnología)

---

## ¿Qué es?

Palier es una página web **de una sola hoja** (sin backend, sin build system) que compara las condiciones de créditos hipotecarios UVA de **14 bancos argentinos**. Tiene tres secciones navegables por tab:

- **Comparador** — tabla de bancos con tasas, plazos, financiación, filtros y el ratio histórico UVA/CCL para contexto de mercado
- **Calculadora** — simulador interactivo de primera cuota con sliders, proyección a 24 meses y umbral de ingreso necesario
- **Guía UVA** — explicación de qué es la UVA, cómo funciona el crédito, el ratio, el sistema francés, precancelación y glosario

Los datos del BCRA (valor UVA, tipo de cambio) se cargan en tiempo real al abrir la página.

---

## Funcionalidades

| Feature                                                 | Estado |
| ------------------------------------------------------- | ------ |
| Tabla comparativa de 14 bancos                          | ✅     |
| Semáforo de tasas (verde / amarillo / rojo)             | ✅     |
| Filtros: monotributistas, refacción, construcción       | ✅     |
| Ordenamiento por columna (click en header)              | ✅     |
| Top 3 mejores tasas                                     | ✅     |
| Datos en vivo: UVA y CCL (BCRA + DolarAPI)              | ✅     |
| Ratio UVA/CCL histórico con datos reales (2016–hoy)     | ✅     |
| Promedio histórico calculado dinámicamente desde la API | ✅     |
| Modo oscuro / claro                                     | ✅     |
| Links directos al sitio oficial de cada banco           | ✅     |
| Tooltips contextuales (SMVM, C/I)                       | ✅     |
| **Calculadora de cuota interactiva**                    | ✅     |
| **Proyección de cuotas 24 meses**                       | ✅     |
| **Guía UVA** (qué es, cómo funciona, glosario)          | ✅     |
| Alertas de cambio de tasa                               | 🔜     |

---

## Tecnología

- **HTML / CSS / JS** — archivo único `index.html`, sin dependencias de build
- **[Tailwind CSS CDN](https://cdn.tailwindcss.com)** — utilidades de layout
- **[Chart.js 4.4](https://www.chartjs.org/)** — gráfico de ratio UVA/CCL e histograma de proyección
- **[Google Fonts](https://fonts.google.com/)** — IBM Plex Sans · IBM Plex Mono
- **[BCRA API v4.0](https://api.bcra.gob.ar)** — UVA y TC BNA en tiempo real
- **[DolarAPI](https://dolarapi.com)** — CCL (Contado con Liquidación) en tiempo real

---

## Correr localmente

> Abriendo el archivo directamente desde el sistema de archivos (`file://`) el navegador bloquea las llamadas a APIs externas por política CORS. Necesitás servirlo desde `localhost`.

```bash
# Opción 1 — Python (sin instalar nada)
python3 -m http.server 8080
# → http://localhost:8080

# Opción 2 — script incluido
chmod +x serve.sh && ./serve.sh

# Opción 3 — Node.js
npx serve .
```

> La página detecta automáticamente si está corriendo desde `file://` y muestra un aviso con estas instrucciones.

---

## APIs utilizadas

```
# UVA actual + histórico completo (paginado)
GET https://api.bcra.gob.ar/estadisticas/v4.0/Monetarias/31

# TC BNA reciente (solo primera página ~3 meses, para meses nuevos no cubiertos)
GET https://api.bcra.gob.ar/estadisticas/v4.0/Monetarias/4

# CCL actual (stats strip, banner, calculadora)
GET https://dolarapi.com/v1/dolares/contadoconliqui

# CCL histórico 2016-2026: hardcodeado en DOLLAR_CCL_MONTHLY
# (promedios mensuales de Bluelytics — blue como proxy CCL)
```

---

## Metodología del gráfico UVA/CCL

El ratio `UVA / dólar CCL` es el indicador central del producto: determina si es buen momento para tomar o precancelar un crédito hipotecario UVA.

**Fuente del dollar histórico:**

| Período      | Fuente                           | Motivo                                    |
| ------------ | -------------------------------- | ----------------------------------------- |
| 2016–2026-05 | `DOLLAR_CCL_MONTHLY` hardcodeado | CCL real de Bluelytics (blue ≈ CCL ±2-5%) |
| Meses nuevos | BCRA TC BNA (primera página)     | Post-cepo 2023: spread BNA/CCL < 2%       |
| Hoy          | DolarAPI CCL en vivo             | Exacto                                    |

**Por qué no se usa el TC BNA oficial para todo el período:**
Durante los cepos cambiarios 2019–2023, el TC oficial estaba fijo mientras el CCL libre llegó a triplicarlo (spreads del 80–158%). Usar TC oficial distorsionaría fuertemente la historia del ratio en ese período. Los valores de `DOLLAR_CCL_MONTHLY` corrigen esto con datos reales del mercado.

**Promedio histórico:** se calcula dinámicamente al cargar la serie completa desde la API (no es el 0,82 hardcodeado del pasado).

---

## Actualización de datos de bancos

Los datos de los bancos (tasas, plazos, montos, etc.) son **manuales** — están en el array `banks[]` dentro de `index.html`. Cuando un banco cambia condiciones, editar el objeto correspondiente.

Los valores de UVA, CCL y el ratio histórico **se actualizan solos** al cargar la página.

---

## Estructura del proyecto

```
palier/
├── index.html      ← toda la aplicación (HTML + CSS + JS)
├── serve.sh        ← servidor local con Python/Node
├── CLAUDE.md       ← guía para agentes de IA trabajando en el proyecto
├── README.md       ← este archivo
└── SPEC.md         ← especificación de features y criterios de aceptación

```

---

## Autor

Hecho por [@\_ignx](https://x.com/_ignx) · Buenos Aires, Argentina.

---

## Disclaimer

La información es **orientativa**. Siempre verificá condiciones actualizadas en el sitio oficial de cada banco antes de operar.
