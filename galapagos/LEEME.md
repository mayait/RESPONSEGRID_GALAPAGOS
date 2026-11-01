# ResponseGrid Galápagos: experimento local

Instancia local de [ResponseGrid](https://github.com/GlobalEmergency/ResponseGrid) (Global Emergency, AGPL-3.0) adaptada a la emergencia por inundaciones de El Niño en Galápagos (oct–nov 2026). La prioridad es Santa Cruz; también cubre San Cristóbal e Isabela.

## Arrancar

```bash
./galapagos/arrancar.sh            # Postgres + Redis (Homebrew), API :3000, web :3001
./galapagos/arrancar.sh --rebuild  # después de cambiar código de la web
```

- Página pública: http://localhost:3001/e/galapagos-2026
- Acceso admin: ver `galapagos/credenciales-locales.txt` (permisos 600, no compartir)
- API / Swagger: http://localhost:3000/docs
- Base de datos: `postgres://reliefhub:reliefhub@localhost:5432/galapagos`

Para validar el mapa hay que usar el modo producción (`next start`). En modo `next dev` la pestaña del navegador se congeló.

## Qué se cambió respecto al original

| Cambio | Archivo |
|---|---|
| Selector de capas: calles OSM, topografía con curvas de nivel (OpenTopoMap), satélite, relieve sombreado, vías OSM por jerarquía, quebradas y drenajes, áreas afectadas | `app/apps/web/src/components/organisms/galapagos-map-layers.tsx` |
| Botones Santa Cruz / San Cristóbal / Isabela y botón **+ Cargar capa** (GeoJSON) | ídem |
| Mapa centrado en Santa Cruz; el encuadre inicial prioriza los puntos de la isla | `emergency-map.tsx` |
| Bots de WhatsApp/Telegram de Venezuela ocultos (`NEXT_PUBLIC_AID_BOTS_ENABLED=false`) | `lib/bots.ts` y sus consumidores |
| Teléfono de ejemplo en formato Ecuador (+593) | formularios de registro |

## Capas de datos (`app/apps/web/public/galapagos/`)

- `vias-osm.geojson`: 2 244 vías de las tres islas (OSM, 1-nov-2026)
- `drenajes-osm.geojson`: 66 quebradas, canales y drenajes (OSM)
- `areas-afectadas.geojson`: capa provisional con La Cascada y la zona de Puerto Ayora sin agua de red. Los límites son **aproximados** (círculos). Hay que reemplazarla por delimitaciones oficiales (COE/SNGR, Copernicus EMS, vuelos de dron).

Las propiedades que lee la capa de áreas son `nombre`, `tipo` (`inundacion` | `servicio` | `deslave` | `riesgo`), `estado` (`validada` muestra la línea continua; cualquier otro valor, discontinua), `fuente`, `fecha` y `detalle`. Una capa que alguien suba con **+ Cargar capa** solo se ve en su navegador. Para que la vean todos, reemplaza el archivo y vuelve a construir la web.

## Datos precargados (`seed-galapagos.mjs`)

Salen de los chats de coordinación del 31-oct. Están **anonimizados**: no incluyen nombres de afectados ni estados de salud.

- Emergencia activa con el comunicado oficial
- Organización: USFQ Galápagos
- 4 puntos: acopio GSC (San Cristóbal), recepción de carga en Puerto Ayora (Viamar), Hotel Flamingo y oficina USFQ Santa Cruz
- 6 necesidades validadas: repelente y mosquiteros, agua, ropa por tallas, kits, alojamiento y power banks
- 6 tareas de voluntariado (dos de ellas en Bellavista e Isabela)
- 1 expedición: GSC → Viamar, 5 cajas

Hay que confirmar las ubicaciones de Viamar y de la oficina USFQ Santa Cruz, que están marcadas «por confirmar».

## Para llevarlo a producción

1. Desplegarlo en un servidor con HTTPS. Las opciones están en `app/docs/deploy/`.
2. Configurar Google OAuth (`GOOGLE_CLIENT_ID/SECRET`) si se quiere el botón «Continuar con Google».
3. Decidir quién valida necesidades y puntos (coordinadores por organización).
4. AGPL-3.0: si se publica, el código modificado debe quedar disponible.

## Capas cartográficas (actualización del 1-nov-2026)

El mapa usa ahora el componente genérico `EmergencyLayers`, que lee `public/capas/galapagos-2026/capas.json`. Las capas, su documentación y el paquete para pedir a ResponseGrid que las incorpore están en **`../mapas-galapagos/`**; se generan desde `../geodatos/`. Para actualizar las áreas afectadas, ver `mapas-galapagos/documentacion/05-como-actualizar.md`.

## Marca (co-branding USFQ Galápagos × ResponseGrid)

- Sistema USFQ WE WANT MORE: solo rojo #E11B22, negro y blanco. Zalando Sans Expanded en titulares y Helvetica Neue en el cuerpo. Los tokens están en `apps/web/src/app/globals.css`; los nombres de upstream se mantienen («navy» ahora es negro y «accent» es el rojo USFQ).
- Logos en `apps/web/public/marca/`, copiados de `MORE_HUMANS_MORE_DRAGONS/03_Propuesta_USFQ_Galapagos/07_Logos/`. La fuente está en `apps/web/src/app/fonts/` (licencia OFL).
- `lib/marca.ts` reúne los nombres y enlaces. `brand-logo.tsx` arma el lockup USFQ | GALÁPAGOS × ResponseGrid. El pie de página lleva la atribución a ResponseGrid y Global Emergency (AGPL-3.0), el cierre «MORE HUMANS, MORE DRAGONS.» y «Desarrollado por IA Humana · iahumana.org».
- Pendiente:
  - validación institucional del lockup por Comunicación;
  - política de privacidad y términos propios de la USFQ (hoy enlazan a los de Global Emergency);
  - publicar el código del fork y apuntar `GITHUB_REPO_URL` a ese repositorio (lo exige la AGPL).

## Portada, organizaciones y albergues (1-nov-2026, 12:20)

- **Portada `/`:** reemplaza el directorio genérico de ResponseGrid con «Gestión de Emergencias — Sociedad Civil Galápagos».
  - El texto fijo se edita en `apps/web/src/lib/portada-galapagos.ts`: albergues, agua, clima, lo que viene en camino, organizaciones, «Cuídate» y la fecha de actualización.
  - «Lo que se necesita hoy» se lee en vivo de las necesidades validadas de la plataforma.
- **Grupos de WhatsApp:** con QR, en `apps/web/src/lib/grupos-whatsapp.ts`. Se muestran en la portada, la página de la emergencia y el formulario de voluntariado.
- **Precarga** (`seed-galapagos.mjs`):
  - 8 organizaciones aliadas, solo instituciones, sin contactos personales.
  - Centro de acopio oficial Cazares y 5 albergues, con coordenadas de OSM. El techado de Las Palmas está ubicado en el centro del barrio (CGREG) y falta ubicarlo exactamente.
  - Necesidades del 1-nov y tareas con Funcavid y ECOS.
  - Comunicado actualizado.
- **Voluntariado:**
  - Ya no pide municipio; se guarda «Galápagos».
  - Teléfono en formato 0999 123 456.
  - Capacidades nuevas en la API: `ngo` (ONG) y `government` (Organismo estatal).
- **«Qué NO hacer»:** son los cuatro puntos de `dont_bring_items` en `i18n/messages/es.ts`.
