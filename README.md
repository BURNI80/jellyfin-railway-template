# Jellyfin on Railway — with web uploader

[![Deploy on Railway](https://railway.com/button.svg)](https://railway.com/template/REPLACE_WITH_YOUR_TEMPLATE_ID)

One-click Jellyfin media server on Railway with a built-in **web file uploader** and **persistent storage**.

- **Jellyfin 10.10.7** — free and open-source media server (movies, TV, music)
- **FileBrowser** — upload your media from the browser at `/files`
- **Persistent volume** — config, metadata and media survive redeploys
- **nginx** — single public entry point, no configuration needed
- **CLI uploads** — also works with `railway volume browse` / `railway volume files`

---

## English

### What you get

| Service | URL | Purpose |
|---|---|---|
| Jellyfin | `https://<your-app>.up.railway.app/` | Your media server (setup wizard on first run) |
| FileBrowser | `https://<your-app>.up.railway.app/files/` | Web file uploader (login: `admin`) |

### One-click deploy

1. Click the **Deploy on Railway** button at the top.
2. Railway creates the project, provisions the volume and deploys the image automatically.
3. Open the generated domain to finish the Jellyfin setup wizard.

### First run

- **Jellyfin**: the setup wizard will ask for language, an admin account and libraries.
- **FileBrowser**: log in with user `admin` and the password stored in the `FILEBROWSER_PASSWORD` variable (auto-generated).

### Uploading media

**Option A — Web uploader (FileBrowser)**

1. Open `https://<your-app>.up.railway.app/files/`.
2. Log in with `admin` / your `FILEBROWSER_PASSWORD`.
3. Drag & drop your media into the pre-created folders:
   - `Movies/`
   - `TV Shows/`
   - `Music/`

**Option B — Railway CLI**

```bash
railway link
railway volume browse /config/media
```

or, non-interactively:

```bash
railway volume files upload ./my-movie.mkv /config/media/Movies/
```

### Adding libraries in Jellyfin

When creating a library, point it to the same folders the uploader uses:

| Library type | Path |
|---|---|
| Movies | `/config/media/Movies` |
| Shows | `/config/media/TV Shows` |
| Music | `/config/media/Music` |

> Tip: after uploading media, run **Scan Media Library** in Jellyfin (or wait for the automatic scan).

### Environment variables

| Variable | Default | Description |
|---|---|---|
| `PORT` | `8095` | Internal HTTP port. Must stay `8095` (nginx). |
| `TZ` | `Etc/UTC` | Container timezone. |
| `FILEBROWSER_PASSWORD` | auto-generated | Password for the FileBrowser `admin` user. |

### Storage

The persistent volume is mounted at `/config`. It contains:

- Jellyfin configuration and metadata
- Your media under `/config/media/`

On the **Free** plan the volume is 0.5 GB with a limit of 1 volume per project. For real media collections, use a paid plan and increase the volume size from the Railway dashboard.

### Limitations

- **CPU transcoding only.** Railway does not offer GPUs, so hardware-accelerated transcoding is unavailable. Clients that support **Direct Play** (the Jellyfin apps, most smart TVs) will stream without transcoding.
- **Jellyfin pinned to 10.10.x.** Jellyfin 10.11+ requires at least 2 GiB free on the data directory and refuses to start otherwise, which is incompatible with Railway's free-tier volume size (500 MB). 10.10.7 is the newest version without that requirement.
- **amd64 only.** FileBrowser is bundled as a `linux-amd64` binary (Railway runs amd64).
- FileBrowser is pinned to `v2.63.23` (the project is archived, but this pinned release keeps working).

### Maintenance

- **Logs**: Railway → your service → Logs.
- **Restart**: Railway redeploys the service automatically on failure (restart policy `ON_FAILURE`).
- **Backup**: the whole instance lives in the volume — take a snapshot from the Railway dashboard before major changes.

### Troubleshooting

| Problem | Solution |
|---|---|
| Site returns 502 | Jellyfin is still starting; wait a moment and refresh. Check the logs. |
| FileBrowser shows a login error | Confirm `FILEBROWSER_PASSWORD` is set and restart the service. |
| Media does not appear | Make sure libraries point to `/config/media/...` and run "Scan Media Library". |
| Volume full | Resize it from the volume settings (paid plans). |

---

## Español

### Qué incluye

| Servicio | URL | Función |
|---|---|---|
| Jellyfin | `https://<tu-app>.up.railway.app/` | Tu servidor de media (asistente de configuración al primer inicio) |
| FileBrowser | `https://<tu-app>.up.railway.app/files/` | Subidor web de archivos (usuario: `admin`) |

### Despliegue en un clic

1. Pulsa el botón **Deploy on Railway** de arriba.
2. Railway crea el proyecto, aprovisiona el volumen y despliega la imagen automáticamente.
3. Abre el dominio generado para completar el asistente de Jellyfin.

### Primer arranque

- **Jellyfin**: el asistente pedirá idioma, una cuenta de administrador y bibliotecas.
- **FileBrowser**: inicia sesión con el usuario `admin` y la contraseña de la variable `FILEBROWSER_PASSWORD` (autogenerada).

### Subir media

**Opción A — Subidor web (FileBrowser)**

1. Abre `https://<tu-app>.up.railway.app/files/`.
2. Inicia sesión con `admin` / tu `FILEBROWSER_PASSWORD`.
3. Arrastra y suelta tu media en las carpetas precreadas:
   - `Movies/`
   - `TV Shows/`
   - `Music/`

**Opción B — CLI de Railway**

```bash
railway link
railway volume browse /config/media
```

o de forma no interactiva:

```bash
railway volume files upload ./mi-pelicula.mkv /config/media/Movies/
```

### Añadir bibliotecas en Jellyfin

Al crear una biblioteca, apúntala a las mismas carpetas que usa el subidor:

| Tipo de biblioteca | Ruta |
|---|---|
| Películas | `/config/media/Movies` |
| Series | `/config/media/TV Shows` |
| Música | `/config/media/Music` |

> Consejo: tras subir media, ejecuta **Escanear biblioteca de media** en Jellyfin (o espera el escaneo automático).

### Variables de entorno

| Variable | Valor por defecto | Descripción |
|---|---|---|
| `PORT` | `8095` | Puerto HTTP interno. Debe ser `8095` (nginx). |
| `TZ` | `Etc/UTC` | Zona horaria del contenedor. |
| `FILEBROWSER_PASSWORD` | autogenerada | Contraseña del usuario `admin` de FileBrowser. |

### Almacenamiento

El volumen persistente se monta en `/config`. Contiene:

- Configuración y metadatos de Jellyfin
- Tu media en `/config/media/`

En el plan **Free** el volumen es de 0,5 GB con un límite de 1 volumen por proyecto. Para colecciones reales usa un plan de pago y amplía el volumen desde el panel de Railway.

### Limitaciones

- **Solo transcodificación por CPU.** Railway no ofrece GPUs, así que la transcodificación por hardware no está disponible. Los clientes con **Direct Play** (apps de Jellyfin, la mayoría de smart TVs) reproducirán sin transcodificar.
- **Jellyfin fijado a 10.10.x.** Jellyfin 10.11+ exige al menos 2 GiB libres en el directorio de datos y se niega a arrancar en caso contrario, algo incompatible con el tamaño del volumen del plan Free de Railway (500 MB). 10.10.7 es la versión más reciente sin ese requisito.
- **Solo amd64.** FileBrowser se incluye como binario `linux-amd64` (Railway usa amd64).
- FileBrowser está fijado a `v2.63.23` (el proyecto está archivado, pero esta versión fijada sigue funcionando).

### Mantenimiento

- **Logs**: Railway → tu servicio → Logs.
- **Reinicio**: Railway redeplegará el servicio automáticamente ante fallos (política `ON_FAILURE`).
- **Copia de seguridad**: toda la instancia vive en el volumen — haz un snapshot desde el panel antes de cambios importantes.

### Solución de problemas

| Problema | Solución |
|---|---|
| El sitio devuelve 502 | Jellyfin sigue arrancando; espera y refresca. Revisa los logs. |
| FileBrowser no deja entrar | Comprueba que `FILEBROWSER_PASSWORD` está definida y reinicia el servicio. |
| La media no aparece | Verifica que las bibliotecas apuntan a `/config/media/...` y ejecuta "Escanear biblioteca de media". |
| Volumen lleno | Amplíalo desde los ajustes del volumen (planes de pago). |

---

## Creating this template (maintainer)

To publish this repo as a one-click Railway template:

1. Push this repo to GitHub (**public**).
2. Go to [railway.com/templates](https://railway.com/templates) → **New Template**.
3. Choose the repository and add the service (Railway detects the Dockerfile).
4. **Variables**: `PORT=8095`, `TZ=Etc/UTC`, `FILEBROWSER_PASSWORD=${{ secret(16) }}`.
5. **Volume**: create a volume and attach it to the service at `/config`.
6. **Networking**: generate a public domain (HTTP).
7. Create the template, copy its ID and replace `REPLACE_WITH_YOUR_TEMPLATE_ID` in the deploy button above.

## Crear este template (mantenedor)

Para publicar este repo como template de un clic en Railway:

1. Sube este repo a GitHub (**público**).
2. Ve a [railway.com/templates](https://railway.com/templates) → **New Template**.
3. Elige el repositorio y añade el servicio (Railway detecta el Dockerfile).
4. **Variables**: `PORT=8095`, `TZ=Etc/UTC`, `FILEBROWSER_PASSWORD=${{ secret(16) }}`.
5. **Volumen**: crea un volumen y conéctalo al servicio en `/config`.
6. **Networking**: genera un dominio público (HTTP).
7. Crea el template, copia su ID y sustituye `REPLACE_WITH_YOUR_TEMPLATE_ID` en el botón de arriba.

---

## License

[Jellyfin](https://github.com/jellyfin/jellyfin) is licensed under the GPL v2. [FileBrowser](https://github.com/filebrowser/filebrowser) is licensed under the Apache License 2.0. This template itself is provided as-is.
