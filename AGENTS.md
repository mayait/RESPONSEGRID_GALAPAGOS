# Instrucciones para agentes — RESPONSEGRID_GALAPAGOS

Lee primero [README.md](README.md) y [galapagos/LEEME.md](galapagos/LEEME.md). Este repositorio es la carpeta de trabajo local de SOS Galápagos: casi todo el código vive en otros repositorios. **Es público**: las credenciales locales (`galapagos/credenciales-*.txt`, `.env`) y `logs/` están en `.gitignore` y no se suben.

## Árbol de repositorios de SOS Galápagos

**Estás en:** `RESPONSEGRID_GALAPAGOS`. Ojo con `app/`: es un clon de `sosgalapagos` (punto 5).

<!-- arbol-repos:inicio -->
> **Este bloque es idéntico en los seis repositorios** (en su `AGENTS.md`). Si cambias algo, cámbialo en los seis. Última revisión: 2026-11-22 (el mapa único es `/riesgos/`; el visor de `/mapas` se retiró; todo el clima corre en `sosgalapagos-plataforma`; licencia nueva en `sosgalapagos-datos` y `sosgalapagos-plataforma`).

SOS Galápagos no es un solo repositorio, son seis. No hay organización de GitHub: todos están en la cuenta `mayait`. En la Mac de Julián cada uno se clona en `~/dev/<nombre>`.

| Repositorio | Visibilidad | Qué contiene | Qué publica |
|---|---|---|---|
| [`sosgalapagos`](https://github.com/mayait/sosgalapagos) | público | La plataforma de coordinación: web y API. Es un fork de `GlobalEmergency/ResponseGrid`. También guarda el Caddy y el Docker Compose de **todo** el servidor (`deploy/sosgalapagos/`). | `sosgalapagos.org/` y `/backend` |
| [`sosgalapagos-datos`](https://github.com/mayait/sosgalapagos-datos) | público | Geodatos, estudios de riesgo, modelos y el panel de `/clima/`. Su carpeta `servidores/` es el índice de qué corre dónde. Código con derechos reservados: uso con permiso. | Los datos de `/mapas/…` (capas y descargas, sin visor) y la página de `/clima/` |
| [`sosgalapagos-plataforma`](https://github.com/mayait/sosgalapagos-plataforma) | público | El mapa de riesgos: reportes ciudadanos con vencimiento sobre las capas de riesgo, buscador, descargas e informe. Django + PostGIS. También corre todo el clima (un solo stack, desde el 22-nov-2026). Código con derechos reservados: uso con permiso. Es el único mapa del sitio desde el 21-nov-2026. | `/riesgos/` |
| [`sosgalapagos-bot`](https://github.com/mayait/sosgalapagos-bot) | **privado** | Asistente de WhatsApp: lee grupos, clasifica mensajes y crea pedidos en la plataforma. | Nada en la web; es un servicio systemd aparte (ver su `LEEME.md`) |
| [`RESPONSEGRID_GALAPAGOS`](https://github.com/mayait/RESPONSEGRID_GALAPAGOS) | público | Carpeta de trabajo local: arranque en la Mac y datos semilla. Clona `sosgalapagos` dentro de `app/`, que git ignora. Conserva la historia de geodatos hasta el 2-nov-2026. | Nada |
| [`estudiantes-riesgo-nino`](https://github.com/mayait/estudiantes-riesgo-nino) | **privado** | Viviendas de estudiantes de USFQ Galápagos cruzadas con el riesgo de inundación. Tiene datos personales. | `/usfq/`, con contraseña |

```
                         sosgalapagos.org (un solo servidor, detrás de Cloudflare)
                                          │
              Caddy + Docker Compose: sosgalapagos → deploy/sosgalapagos/
        ┌──────────────┬──────────────────┬──────────────────┬───────────────────────┐
        │ /  /backend  │ /riesgos/        │ /mapas/… /clima/ │ /usfq/ (contraseña)   │
        ▼              ▼                  ▼                  ▼                       │
   sosgalapagos   sosgalapagos-      sosgalapagos-datos   estudiantes-riesgo-nino    │
   (portada y     plataforma         (datos y modelos)    (privado)                  │
    coordinación) (mapa de riesgos)       │                    ▲                     │
        ▲              ▲  lee capas.json, │ capas y descargas  │ capas de geodatos   │
        │              └──────────────────┴────────────────────┘                     │
        │ API pública                                                                │
   sosgalapagos-bot (privado, servicio aparte) ◄─────────────────────────────────────┘

   /mapas/ ya no tiene visor: la página redirige a /riesgos/. Sus datos se siguen sirviendo.
   RESPONSEGRID_GALAPAGOS/app/  =  otro clon local de sosgalapagos
```

### Cómo dependen unos de otros

1. **Las rutas del servidor se definen en `sosgalapagos`.** El `Caddyfile` y el `docker-compose.yml` de `deploy/sosgalapagos/` sirven la plataforma, pasan `/riesgos/` al contenedor de `sosgalapagos-plataforma` (Compose aparte, en la misma red) y montan las carpetas que publican los demás: `/srv/sosgalapagos-mapas` y `/srv/sosgalapagos-clima` (de `sosgalapagos-datos`) y `/srv/sosgalapagos-privado` (de `estudiantes-riesgo-nino`). Una ruta nueva se añade allí y se despliega con `deploy/sosgalapagos/deploy.sh`, aunque el contenido venga de otro repositorio.
2. **Las capas del mapa de la plataforma se generan en `sosgalapagos-datos`** (`geodatos/export/`) y se sirven desde `sosgalapagos` (`apps/web/public/capas/galapagos-2026/`), dentro de la imagen web. Para que un cambio de capa llegue a la plataforma hay que copiarla y desplegar la app. La carpeta `geodatos/` de `sosgalapagos` no recibe cambios desde el 1-nov-2026: el proceso vivo está en `sosgalapagos-datos`.
3. **El bot habla con la plataforma solo por su API pública** (`https://sosgalapagos.org/backend`, cliente en `src/responsegrid.ts`). No toca la base de datos ni el código. Si cambias un endpoint o un DTO de la API en `sosgalapagos`, revisa ese cliente.
4. **`estudiantes-riesgo-nino` lee las capas de `sosgalapagos-datos`.** Su ruta por defecto apunta a la ubicación antigua, que ya no existe: se corre con `GEODATOS=~/dev/sosgalapagos-datos/geodatos`.
5. **`RESPONSEGRID_GALAPAGOS/app/` es un clon de `sosgalapagos`**, no una carpeta del repositorio que lo contiene. Lo que se hace commit allí va a `sosgalapagos`. Como hay dos clones locales del mismo repositorio (`~/dev/sosgalapagos` y `~/dev/RESPONSEGRID_GALAPAGOS/app`), haz `git pull` antes de trabajar en cualquiera.
6. **El mapa de `/riesgos/` lee lo que `sosgalapagos-datos` publica bajo `/mapas/`**: el manifiesto (`capas.json`), las capas, las teselas, `descargas.json` y `version.txt`. Una capa nueva se añade en `sosgalapagos-datos` y aparece sola en `/riesgos/`. **Nunca se da de baja la carpeta de `/mapas/`**: solo se retiró su página, que redirige a `/riesgos/`.

### Dónde va cada cambio

| Quiero cambiar… | Repositorio |
|---|---|
| La web, la API, la portada, formularios o la marca | `sosgalapagos` |
| Una ruta, un contenedor o el Caddy del servidor | `sosgalapagos` → `deploy/sosgalapagos/` |
| El mapa de riesgos: reportes, buscador, panel de capas, informe, página de descargas | `sosgalapagos-plataforma` |
| Una capa, un estudio, un modelo, el orden y los colores de las capas | `sosgalapagos-datos` → `geodatos/` |
| La página del panel de `/clima/` | `sosgalapagos-datos` → `clima/web/` |
| Las fuentes de clima, el nivel de lluvia, el pronóstico, las mareas, el satélite | `sosgalapagos-plataforma` → `clima/` |
| Qué servicio corre dónde y cómo se publica | `sosgalapagos-datos` → `servidores/README.md` |
| Cómo lee, responde o modera el asistente de WhatsApp | `sosgalapagos-bot` |
| El arranque local o los datos semilla | `RESPONSEGRID_GALAPAGOS` → `galapagos/` |
| El mapa o el informe de estudiantes en riesgo | `estudiantes-riesgo-nino` |

### Reglas que cruzan repositorios

- **No se copia código de `sosgalapagos` (AGPL-3.0) a `sosgalapagos-plataforma`** (todos los derechos reservados desde el 22-nov-2026; antes, Apache 2.0).
- **Nada de un repositorio privado pasa a uno público.** Ni los datos personales de `estudiantes-riesgo-nino` ni la lógica de detección de estafas del bot (`src/analista.ts`).
- **Licencias.** `sosgalapagos` es AGPL-3.0 (fork de ResponseGrid) y no cambia. `sosgalapagos-datos` y `sosgalapagos-plataforma` tienen, desde el 22-nov-2026, el código con todos los derechos reservados (usarlo requiere permiso escrito de Julián Maya) y lo propio que no es código bajo CC BY-NC-ND 4.0; cada archivo de código lleva su aviso de autoría. Los datos de terceros conservan la licencia de su fuente.
- **Cada repositorio tiene sus propias reglas de commit y de ramas.** Léelas en su `AGENTS.md` o `LEEME.md` antes de hacer commit. Dos que cambian: en `sosgalapagos` los commits van como «IA Humana» y sin `Co-Authored-By`; en `sosgalapagos-datos` y en `sosgalapagos-plataforma` se trabaja en una rama con pull request, también sin `Co-Authored-By`.
- **Desplegar es un paso aparte y manual.** Subir a `main` no publica nada en `sosgalapagos.org`. No despliegues si no te lo piden.
<!-- arbol-repos:fin -->
