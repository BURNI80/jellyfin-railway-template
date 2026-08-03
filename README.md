# Jellyfin on Railway — with web uploader

[![Deploy on Railway](https://railway.com/button.svg)](https://railway.com/template/REPLACE_WITH_YOUR_TEMPLATE_ID)

One-click Jellyfin media server on Railway with a built-in **web file uploader** and **persistent storage**.

- **Jellyfin 10.10.7** — free and open-source media server (movies, TV, music)
- **FileBrowser** — upload your media from the browser at `/files`
- **Persistent volume** — config, metadata and media survive redeploys
- **nginx** — single public entry point, no configuration needed
- **Everything from the browser** — no SSH, no CLI tools required

---

## Quick start (2 minutes)

1. **Deploy** — click the button above and let Railway build the image.
2. **Configure Jellyfin** — open your domain and complete the setup wizard (language + admin user).
3. **Upload media** — go to `/files`, log in, and drag your movies/series into the folders.
4. **Add libraries** — point Jellyfin libraries to `/config/media/...`.
5. **Watch** — open the Jellyfin mobile app or the web player.

Details for each step below.

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

**Jellyfin**

The setup wizard will ask for:
1. Your display language.
2. An **admin account** (this is your Jellyfin user, not the FileBrowser user — write the credentials down).
3. Libraries — you can skip this step and add them later (recommended, see below).

**FileBrowser**

The web uploader uses a single `admin` user. Its password is the value of the `FILEBROWSER_PASSWORD` variable:

- Find it under **Railway → your service → Variables → `FILEBROWSER_PASSWORD`**.
- If you change that variable, the `admin` password is updated automatically on the next deploy.

### Uploading media (web uploader)

No tools to install — just a browser:

1. Open `https://<your-app>.up.railway.app/files/`.
2. Log in with user `admin` and the password from `FILEBROWSER_PASSWORD`.
3. Enter one of the pre-created folders:
   - `Movies/`
   - `TV Shows/`
   - `Music/`
4. **Drag & drop** your files into the browser window, or use the **Upload** button (up-arrow icon, top right).

Large files are supported (chunked, resumable uploads). You can also create sub-folders with the **New folder** button to organise your collection.

> The uploader's root is `/config/media`, which is exactly where Jellyfin reads your media from.

### Adding libraries in Jellyfin

In the Jellyfin dashboard (gear icon) go to **Libraries → Add Media Library** and create one per type, pointing to the same folders the uploader uses:

| Library type | Path |
|---|---|
| Movies | `/config/media/Movies` |
| Shows | `/config/media/TV Shows` |
| Music | `/config/media/Music` |

> Note the capital letters and the space in `TV Shows`. After uploading media, run **Scan Media Library** (or wait for the automatic scan) so new files appear.

### Mobile apps (phone / tablet)

Jellyfin has official apps for Android and iOS:

1. Install the **Jellyfin** app from the Play Store / App Store.
2. On the server screen, enter your domain: `https://<your-app>.up.railway.app`.
3. Sign in with the **Jellyfin admin user** you created in the wizard (not the FileBrowser user).

**Quick Connect (optional, easier):**

1. In Jellyfin on a desktop browser, open **Dashboard → your avatar → Quick Connect**.
2. In the mobile app choose **Sign in with Quick Connect** and type the 4-digit code.

Notes:

- Your URL uses a valid HTTPS certificate, so ignore any "untrusted certificate" warning if one appears.
- No port forwarding or "External domain" settings are needed — remote streaming works out of the box.

### Environment variables

| Variable | Default | Description |
|---|---|---|
| `PORT` | `8095` | Internal HTTP port. Must stay `8095` (nginx). |
| `TZ` | `Etc/UTC` | Container timezone. |
| `FILEBROWSER_PASSWORD` | auto-generated | Password for the FileBrowser `admin` user. If not set, a password is generated on first boot and stored in the volume at `/config/.filebrowser-password`. Changing this variable later updates the `admin` password on the next deploy. |

### Storage

The persistent volume is mounted at `/config`. It contains:

- Jellyfin configuration and metadata
- Your media under `/config/media/`

On the **Free** plan the volume is 0.5 GB with a limit of 1 volume per project. For real media collections, use a paid plan and increase the volume size from the Railway dashboard.

### Limitations

- **CPU transcoding only.** Railway does not offer GPUs, so hardware-accelerated transcoding is unavailable. Clients that support **Direct Play** (the Jellyfin apps, most smart TVs) will stream without transcoding.
- **Jellyfin pinned to 10.10.x.** Jellyfin 10.11+ requires at least 2 GiB free on the data directory and refuses to start otherwise, which is incompatible with Railway's free-tier volume size (500 MB). 10.10.7 is the newest version without that requirement.
- **Web uploads only.** The `railway volume browse` / `railway volume files` CLI commands require SSH keys that Railway does not provide on this setup — use the FileBrowser web uploader instead.
- **amd64 only.** FileBrowser is bundled as a `linux-amd64` binary (Railway runs amd64).
- FileBrowser is pinned to `v2.63.23` (the project is archived, but this pinned release keeps working).

### Maintenance

- **Logs**: Railway → your service → Logs.
- **Restart**: Railway redeploys the service automatically on failure (restart policy `ON_FAILURE`).
- **Backup**: the whole instance lives in the volume — take a snapshot from the Railway dashboard before major changes.
- **Redeploy after a code change**: pushes to the repository do not auto-deploy in CLI-connected mode; run `railway redeploy --service <id> --from-source -y` or press *Redeploy* in the dashboard.

### Troubleshooting

| Problem | Solution |
|---|---|
| Site returns 502 | Jellyfin is still starting; wait a moment and refresh. Check the logs. |
| FileBrowser shows a login error | Confirm `FILEBROWSER_PASSWORD` is set and restart the service. |
| Media does not appear | Make sure libraries point to `/config/media/...` and run "Scan Media Library". |
| Volume full | Resize it from the volume settings (paid plans). |
| Mobile app can't connect | Double-check the URL is `https://<your-app>.up.railway.app` (with `https://`). |

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

**Jellyfin**

El asistente pedirá:
1. Tu idioma de visualización.
2. Una cuenta de **administrador** (este es tu usuario de Jellyfin, no el de FileBrowser — anota las credenciales).
3. Bibliotecas — puedes saltarte este paso y añadirlas luego (recomendado, ver abajo).

**FileBrowser**

El subidor web usa un único usuario `admin`. Su contraseña es el valor de la variable `FILEBROWSER_PASSWORD`:

- Encuéntrala en **Railway → tu servicio → Variables → `FILEBROWSER_PASSWORD`**.
- Si cambias esa variable, la contraseña de `admin` se actualiza automáticamente en el siguiente deploy.

### Subir media (subidor web)

Sin instalar nada — solo un navegador:

1. Abre `https://<tu-app>.up.railway.app/files/`.
2. Inicia sesión con el usuario `admin` y la contraseña de `FILEBROWSER_PASSWORD`.
3. Entra en una de las carpetas precreadas:
   - `Movies/`
   - `TV Shows/`
   - `Music/`
4. **Arrastra y suelta** tus archivos en la ventana del navegador, o usa el botón **Upload** (icono de flecha arriba, arriba a la derecha).

Los archivos grandes están soportados (subida por trozos, reanudable). También puedes crear subcarpetas con el botón **New folder** para organizar tu colección.

> La raíz del subidor es `/config/media`, que es exactamente de donde Jellyfin lee tu media.

### Añadir bibliotecas en Jellyfin

En el panel de Jellyfin (icono de engranaje) ve a **Libraries → Add Media Library** y crea una por tipo, apuntando a las mismas carpetas que usa el subidor:

| Tipo de biblioteca | Ruta |
|---|---|
| Películas | `/config/media/Movies` |
| Series | `/config/media/TV Shows` |
| Música | `/config/media/Music` |

> Ojo con las mayúsculas y el espacio en `TV Shows`. Tras subir media, ejecuta **Escanear biblioteca de media** (o espera el escaneo automático) para que aparezcan los archivos nuevos.

### Apps móviles (móvil / tablet)

Jellyfin tiene apps oficiales para Android e iOS:

1. Instala la app **Jellyfin** desde Play Store / App Store.
2. En la pantalla de servidor, introduce tu dominio: `https://<tu-app>.up.railway.app`.
3. Inicia sesión con el **usuario admin de Jellyfin** que creaste en el asistente (no el de FileBrowser).

**Quick Connect (opcional, más cómodo):**

1. En Jellyfin desde un navegador de escritorio, abre **Dashboard → tu avatar → Quick Connect**.
2. En la app móvil elige **Sign in with Quick Connect** e introduce el código de 4 dígitos.

Notas:

- Tu URL usa un certificado HTTPS válido; ignora cualquier aviso de "certificado no confiable" si aparece.
- No hace falta port forwarding ni ajustes de "External domain" — el streaming remoto funciona directamente.

### Variables de entorno

| Variable | Valor por defecto | Descripción |
|---|---|---|
| `PORT` | `8095` | Puerto HTTP interno. Debe ser `8095` (nginx). |
| `TZ` | `Etc/UTC` | Zona horaria del contenedor. |
| `FILEBROWSER_PASSWORD` | autogenerada | Contraseña del usuario `admin` de FileBrowser. Si no se define, se genera en el primer arranque y se guarda en el volumen en `/config/.filebrowser-password`. Cambiar esta variable más adelante actualiza la contraseña de `admin` en el siguiente deploy. |

### Almacenamiento

El volumen persistente se monta en `/config`. Contiene:

- Configuración y metadatos de Jellyfin
- Tu media en `/config/media/`

En el plan **Free** el volumen es de 0,5 GB con un límite de 1 volumen por proyecto. Para colecciones reales usa un plan de pago y amplía el volumen desde el panel de Railway.

### Limitaciones

- **Solo transcodificación por CPU.** Railway no ofrece GPUs, así que la transcodificación por hardware no está disponible. Los clientes con **Direct Play** (apps de Jellyfin, la mayoría de smart TVs) reproducirán sin transcodificar.
- **Jellyfin fijado a 10.10.x.** Jellyfin 10.11+ exige al menos 2 GiB libres en el directorio de datos y se niega a arrancar en caso contrario, algo incompatible con el tamaño del volumen del plan Free de Railway (500 MB). 10.10.7 es la versión más reciente sin ese requisito.
- **Solo subidas web.** Los comandos CLI `railway volume browse` / `railway volume files` requieren claves SSH que Railway no proporciona en este setup — usa el subidor web de FileBrowser.
- **Solo amd64.** FileBrowser se incluye como binario `linux-amd64` (Railway usa amd64).
- FileBrowser está fijado a `v2.63.23` (el proyecto está archivado, pero esta versión fijada sigue funcionando).

### Mantenimiento

- **Logs**: Railway → tu servicio → Logs.
- **Reinicio**: Railway redeplegará el servicio automáticamente ante fallos (política `ON_FAILURE`).
- **Copia de seguridad**: toda la instancia vive en el volumen — haz un snapshot desde el panel antes de cambios importantes.
- **Redeploy tras un cambio de código**: los push al repositorio no despliegan solos en modo conectado por CLI; ejecuta `railway redeploy --service <id> --from-source -y` o pulsa *Redeploy* en el panel.

### Solución de problemas

| Problema | Solución |
|---|---|
| El sitio devuelve 502 | Jellyfin sigue arrancando; espera y refresca. Revisa los logs. |
| FileBrowser no deja entrar | Comprueba que `FILEBROWSER_PASSWORD` está definida y reinicia el servicio. |
| La media no aparece | Verifica que las bibliotecas apuntan a `/config/media/...` y ejecuta "Escanear biblioteca de media". |
| Volumen lleno | Amplíalo desde los ajustes del volumen (planes de pago). |
| La app móvil no conecta | Revisa que la URL es `https://<tu-app>.up.railway.app` (con `https://`). |

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
