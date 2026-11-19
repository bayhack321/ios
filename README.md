# Mangis para iPhone (Flutter nativo)

Proyecto iOS separado, hecho con Flutter y widgets nativos. No usa Safari, PWA,
WebView ni inicio de sesión con Google. Guarda el perfil, las direcciones, el
carrito y los pedidos localmente en el iPhone para una prueba sin servidor.

## Compilar

El workflow **Build unsigned iOS IPA** corre en GitHub Actions sobre macOS.
Cada push a `main` también inicia una compilación. El resultado es un IPA sin
firma en el artefacto `Mangis-unsigned-IPA`.

## Instalar con AltStore

1. Descargá `Mangis.ipa` desde el artefacto de una compilación exitosa.
2. En la computadora, abrí AltServer e instalá AltStore en el iPhone.
3. En AltStore, elegí **My Apps > + > Mangis.ipa** y firmá con tu Apple ID.
4. Conectá el iPhone a AltServer por Wi-Fi o USB para renovar la instalación
   gratuita cuando AltStore lo indique (normalmente cada siete días).

El IPA que produce Actions es deliberadamente sin firmar: no requiere subir a
GitHub certificados, contraseñas ni claves privadas. AltStore firma la copia
al instalarla.

## Alcance del modo local

El primer inicio pide nombre, teléfono y dirección. El catálogo incluye los
cuatro rubros; el carrito, perfil, múltiples direcciones y pedidos se guardan
en el dispositivo. Este modo no inicia sesión en Google, no sincroniza cuentas,
menú, direcciones ni pedidos con Mangis API, no publica productos y no procesa
pagos. El mapa de dirección usa OpenStreetMap; la ubicación se solicita solo
si se pulsa el botón correspondiente en el selector de dirección.

El código Android y el proyecto PHP original no forman parte de este repositorio
y no se modifican.
