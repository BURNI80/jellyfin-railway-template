# Jellyfin on Railway — with web uploader

[![Deploy on Railway](https://railway.com/button.svg)](https://railway.com/template/REPLACE_WITH_YOUR_TEMPLATE_ID)

One-click Jellyfin media server on Railway with a built-in **web portal** (FileBrowser) for uploading your media, and **persistent storage**.

- **Jellyfin 10.10.7** — free and open-source media server (movies, TV, music)
- **Web portal** — upload, organise and manage your media from any browser at `/files`
- **Persistent volume** — config, metadata and media survive redeploys
- **nginx** — single public entry point, no configuration needed
- **Everything from the browser** — no SSH, no terminal, no extra tools

---

## Quick start (2 minutes)

1. **Deploy** — click the button above and let Railway build the image.
2. **Configure Jellyfin** — open your domain and complete the setup wizard (language + admin user).
3. **Upload media** — open the web portal at `/files`, log in and drag your movies/series into the folders.
4. **Add libraries** — point Jellyfin libraries to `/config/media/...`.
5. **Watch anywhere** — open the Jellyfin web player or the mobile app.

Details for each step below.

---

## English

### What you get

| Service | URL | Purpose |
|---|---|---|
| Jellyfin | `https://<your-app>.up.railway.app/` | Your media server — watch and organise everything |
| Web portal | `https://<your-app>.up.railway.app/files/` | Upload and manage your media files (login: `admin`) |

### One-click deploy

1. Click the **Deploy on Railway** button at the top.
2. Railway creates the project, provisions the volume and deploys the image automatically.
3. Open the generated domain to finish the Jellyfin setup wizard.

### First run

**Jellyfin**

The setup wizard will ask for:
1. Your display language.
2. An **admin account** (this is your Jellyfin user — write the credentials down).
3. Libraries — you can skip this step and add them later (recommended, see below).

**Web portal (FileBrowser)**

The portal uses a single `admin` user. Its password is the value of the `FILEBROWSER_PASSWORD` variable:

- Find it under **Railway → your service → Variables → `FILEBROWSER_PASSWORD`**.
- If you change that variable, the portal password is updated automatically on the next deploy.

---

### The web portal — how to use it

The portal at `/files` is the easiest way to get your media onto the server. Everything happens in the browser.

**Log in**

1. Open `https://<your-app>.up.railway.app/files/`.
2. Enter user `admin` and the password from `FILEBROWSER_PASSWORD`.
3. You will see three ready-made folders: `Movies`, `TV Shows` and `Music`.

**Upload files**

1. Open the folder where you want the file to go (e.g. `Movies`).
2. **Drag & drop** your files from your computer into the browser window, **or**
3. Click the **Upload** button (up-arrow icon, top right) and select the files.
4. Wait for the upload to finish (a progress bar shows in the top-right corner).

Large files are supported: uploads run in chunks and can resume if the connection drops, so a 2 GB movie is fine.

**Organise your media**

- **New folder** — create sub-folders inside `Movies`, `TV Shows`, etc. to organise by genre, year or whatever you like.
- **Rename** — select a file/folder and click **Rename**, or right-click it.
- **Move** — drag a file onto another folder, or use the **Move** action.
- **Delete** — select and delete (moves to trash first, if trash is enabled).
- **Search** — the search box (top left) finds files instantly by name.

The portal's root is `/config/media`, which is exactly where Jellyfin reads your media from, so anything you upload is immediately visible to Jellyfin after a library scan.

---

### Adding libraries in Jellyfin

In the Jellyfin dashboard (gear icon) go to **Libraries → Add Media Library** and create one per type, pointing to the same folders the portal uses:

| Library type | Path |
|---|---|
| Movies | `/config/media/Movies` |
| Shows | `/config/media/TV Shows` |
| Music | `/config/media/Music` |

> Note the capital letters and the space in `TV Shows`. After uploading media, run **Scan Media Library** (or wait for the automatic scan) so new files appear.

### Connecting from a PC

The simplest option needs no install at all:

1. Open **https://<your-app>.up.railway.app/** in your browser.
2. Log in with your **Jellyfin admin user**.
3. Browse your libraries and press play.

Optional — the **Jellyfin desktop app** (Windows / macOS / Linux):

1. Download it from [jellyfin.org/downloads](https://jellyfin.org/downloads) (or the Microsoft Store).
2. On first launch, add your server: enter `https://<your-app>.up.railway.app` and sign in.
3. The desktop app behaves like the web player but with native shortcuts and windowing.

### Connecting from mobile (Android / iOS)

Jellyfin has official apps for phones and tablets:

1. Install the **Jellyfin** app from the Play Store or App Store.
2. On the server screen, enter your domain: `https://<your-app>.up.railway.app`.
3. Sign in with your **Jellyfin admin user** (the one from the wizard — not the portal user).

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
| `FILEBROWSER_PASSWORD` | auto-generated | Password for the portal `admin` user. If not set, a password is generated on first boot and stored in the volume at `/config/.filebrowser-password`. Changing this variable later updates the `admin` password on the next deploy. |

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
- **Redeploy after a code change**: push a change and press **Redeploy** in the Railway dashboard.
- **Backup**: the whole instance lives in the volume — take a snapshot from the Railway dashboard before major changes.

### Troubleshooting

| Problem | Solution |
|---|---|
| Site returns 502 | Jellyfin is still starting; wait a moment and refresh. Check the logs. |
| Portal shows a login error | Confirm `FILEBROWSER_PASSWORD` is set and restart the service. |
| Media does not appear | Make sure libraries point to `/config/media/...` and run "Scan Media Library". |
| Volume full | Resize it from the volume settings (paid plans). |
| Mobile app can't connect | Double-check the URL is `https://<your-app>.up.railway.app` (with `https://`). |

---

## Español

### Qué incluye

| Servicio | URL | Función |
|---|---|---|
| Jellyfin | `https://<tu-app>.up.railway.app/` | Tu servidor de media — ve y organiza todo |
| Portal web | `https://<tu-app>.up.railway.app/files/` | Sube y gestiona tus archivos de media (usuario: `admin`) |

### Despliegue en un clic

1. Pulsa el botón **Deploy on Railway** de arriba.
2. Railway crea el proyecto, aprovisiona el volumen y despliega la imagen automáticamente.
3. Abre el dominio generado para completar el asistente de Jellyfin.

### Primer arranque

**Jellyfin**

El asistente pedirá:
1. Tu idioma de visualización.
2. Una cuenta de **administrador** (este es tu usuario de Jellyfin — anota las credenciales).
3. Bibliotecas — puedes saltarte este paso y añadirlas luego (recomendado, ver abajo).

**Portal web (FileBrowser)**

El portal usa un único usuario `admin`. Su contraseña es el valor de la variable `FILEBROWSER_PASSWORD`:

- Encuéntrala en **Railway → tu servicio → Variables → `FILEBROWSER_PASSWORD`**.
- Si cambias esa variable, la contraseña del portal se actualiza automáticamente en el siguiente deploy.

---

### El portal web — cómo usarlo

El portal en `/files` es la forma más fácil de meter tu media en el servidor. Todo ocurre en el navegador.

**Iniciar sesión**

1. Abre `https://<tu-app>.up.railway.app/files/`.
2. Introduce el usuario `admin` y la contraseña de `FILEBROWSER_PASSWORD`.
3. Verás tres carpetas ya creadas: `Movies`, `TV Shows` y `Music`.

**Subir archivos**

1. Entra en la carpeta donde quieras el archivo (p. ej. `Movies`).
2. **Arrastra y suelta** tus archivos desde el ordenador a la ventana del navegador, **o**
3. Pulsa el botón **Upload** (icono de flecha arriba, arriba a la derecha) y selecciona los archivos.
4. Espera a que termine la subida (verás una barra de progreso en la esquina superior derecha).

Los archivos grandes están soportados: las subidas van por trozos y se pueden reanudar si se cae la conexión, así que una película de 2 GB no es problema.

**Organizar tu media**

- **New folder** — crea subcarpetas dentro de `Movies`, `TV Shows`, etc. para organizar por género, año o lo que quieras.
- **Rename** — selecciona un archivo/carpeta y pulsa **Rename**, o haz clic derecho.
- **Move** — arrastra un archivo a otra carpeta, o usa la acción **Move**.
- **Delete** — selecciona y elimina (pasa a la papelera primero, si la papelera está activada).
- **Search** — el buscador (arriba a la izquierda) encuentra archivos al instante por nombre.

La raíz del portal es `/config/media`, que es exactamente de donde Jellyfin lee tu media, así que todo lo que subas estará visible para Jellyfin tras un escaneo de biblioteca.

---

### Añadir bibliotecas en Jellyfin

En el panel de Jellyfin (icono de engranaje) ve a **Libraries → Add Media Library** y crea una por tipo, apuntando a las mismas carpetas que usa el portal:

| Tipo de biblioteca | Ruta |
|---|---|
| Películas | `/config/media/Movies` |
| Series | `/config/media/TV Shows` |
| Música | `/config/media/Music` |

> Ojo con las mayúsculas y el espacio en `TV Shows`. Tras subir media, ejecuta **Escanear biblioteca de media** (o espera el escaneo automático) para que aparezcan los archivos nuevos.

### Conectar desde un PC

La opción más sencilla no necesita instalar nada:

1. Abre **https://<tu-app>.up.railway.app/** en tu navegador.
2. Inicia sesión con tu **usuario admin de Jellyfin**.
3. Navega por tus bibliotecas y pulsa reproducir.

Opcional — la **app de escritorio de Jellyfin** (Windows / macOS / Linux):

1. Descárgala de [jellyfin.org/downloads](https://jellyfin.org/downloads) (o de Microsoft Store).
2. En el primer arranque, añade tu servidor: introduce `https://<tu-app>.up.railway.app` e inicia sesión.
3. La app de escritorio funciona como el reproductor web, pero con accesos rápidos nativos y ventana propia.

### Conectar desde el móvil (Android / iOS)

Jellyfin tiene apps oficiales para móviles y tablets:

1. Instala la app **Jellyfin** desde Play Store o App Store.
2. En la pantalla de servidor, introduce tu dominio: `https://<tu-app>.up.railway.app`.
3. Inicia sesión con tu **usuario admin de Jellyfin** (el del asistente — no el usuario del portal).

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
| `FILEBROWSER_PASSWORD` | autogenerada | Contraseña del usuario `admin` del portal. Si no se define, se genera en el primer arranque y se guarda en el volumen en `/config/.filebrowser-password`. Cambiar esta variable más adelante actualiza la contraseña de `admin` en el siguiente deploy. |

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
- **Redeploy tras un cambio de código**: haz push y pulsa **Redeploy** en el panel de Railway.
- **Copia de seguridad**: toda la instancia vive en el volumen — haz un snapshot desde el panel antes de cambios importantes.

### Solución de problemas

| Problema | Solución |
|---|---|
| El sitio devuelve 502 | Jellyfin sigue arrancando; espera y refresca. Revisa los logs. |
| El portal no deja entrar | Comprueba que `FILEBROWSER_PASSWORD` está definida y reinicia el servicio. |
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
