# SMS Blocker para iOS


<div style="display: flex; align-items: center; gap: 20px;">
  <img src="https://github.com/jcmartinezreyes/SMS-blocker_IOS/raw/main/images/31D539A6-8C4C-46E8-A627-1625B511AA24_1_105_c.jpeg" alt="SMS Blocker Icon" width="128"/>
  <div>
    <h3>SMS Blocker para iOS</h3>
    <p>SMS Blocker es una sencilla pero potente aplicación para iOS diseñada para ayudarte a recuperar el control de tu bandeja de entrada de mensajes. Añade palabras clave o frases a tu lista de filtros y la aplicación bloqueará automáticamente los mensajes SMS/MMS no deseados que las contengan.</p>
  </div>
</div>


## ✨ Características

-   **Lista de Filtros Personalizable:** Añade cualquier palabra, frase o número que desees bloquear.
-   **Interfaz Sencilla:** Una interfaz limpia y directa construida con SwiftUI para gestionar tus filtros fácilmente.
-   **Añadir, Editar y Eliminar:** Administra tu lista de filtros con gestos intuitivos de `swipe` para editar o borrar.
-   **Sincronización en Tiempo Real:** Los filtros se guardan y se sincronizan instantáneamente con la extensión de filtrado de mensajes de iOS.
-   **Privacidad Primero:** Todo el procesamiento se realiza de forma local en tu dispositivo. Tus mensajes nunca salen de tu teléfono.

## 📸 Capturas de Pantalla

| Vista Principal | Alerta para Añadir Filtro |
| :-------------: | :-----------------------: |
| ![Vista Principal de SMS Blocker](https://github.com/jcmartinezreyes/SMS-blocker_IOS/blob/main/images/688022AB-32AD-4582-B868-7653FAC75960_4_5005_c.jpeg) | ![Añadir un nuevo filtro](Uhttps://github.com/jcmartinezreyes/SMS-blocker_IOS/blob/main/images/20AA41E0-E372-4996-A861-3D55EDED9FF8_4_5005_c.jpeg) |

## 🛠️ Cómo Funciona

La aplicación consta de dos componentes principales:

1.  **La App Principal (`SMS Blocker`):** Una interfaz de usuario construida con SwiftUI que permite a los usuarios gestionar una lista de palabras clave para el filtrado.
2.  **La Extensión de Filtrado de Mensajes (`SMSBlockerFilterExtension`):** Utiliza el framework `IdentityLookup` de Apple para interceptar los mensajes entrantes. Compara el contenido del mensaje con la lista de filtros del usuario.

Ambos componentes se comunican de forma segura a través de un **App Group**, utilizando `UserDefaults` para compartir la lista de filtros. Cuando un usuario añade o modifica un filtro en la app principal, esta lista se codifica en formato JSON y se guarda en el contenedor compartido, donde la extensión puede leerla y aplicarla al instante.

## 🚀 Requisitos

-   iOS 18.0 o superior (según la configuración de tu proyecto)
-   Xcode 16.0 o superior
-   Swift 5.x

## ⚙️ Instalación y Configuración

Para compilar y ejecutar este proyecto en tu propio dispositivo, sigue estos pasos:

1.  **Clona el repositorio:**
    ```bash
    git clone [https://URL-DE-TU-REPOSITORIO.git](https://URL-DE-TU-REPOSITORIO.git)
    cd nombre-del-directorio
    ```

2.  **Abre en Xcode:**
    Abre el archivo `.xcodeproj` o `.xcworkspace`.

3.  **Configura la Firma y el App Group:**
    -   En la configuración del proyecto, selecciona el target `SMS Blocker`.
    -   Ve a la pestaña "Signing & Capabilities".
    -   Selecciona tu equipo de desarrollo (Developer Team).
    -   Bajo "App Groups", asegúrate de que el grupo (`group.jcm.SMS-Blocker` en tu caso) esté registrado en tu cuenta de desarrollador y seleccionado. Xcode podría mostrar un error si el App Group no está asociado a tu cuenta; si es necesario, crea uno nuevo y actualiza el nombre en el código.
    -   **Repite este paso** para el target `SMSBlockerFilterExtension`. Ambos targets deben compartir el mismo App Group.

4.  **Compila y ejecuta** la aplicación en un dispositivo físico. Las extensiones de filtrado de SMS no se pueden probar completamente en el simulador de iOS.

## 📋 Cómo Usar la App

Una vez instalada en tu iPhone, debes habilitar el filtro de mensajes:

1.  Abre la aplicación **Ajustes** en tu iPhone.
2.  Desplázate hacia abajo y selecciona **Mensajes**.
3.  Pulsa en **Desconocido y no deseado**.
4.  Bajo **Filtrado de Mensajes**, activa el interruptor para **SMS Blocker**.

¡Listo! A partir de ahora, la aplicación filtrará los mensajes que contengan las palabras clave que hayas definido en tu lista.

## 📄 Licencia

Este proyecto está bajo la Licencia MIT. Consulta el archivo `LICENSE` para más detalles.

---
[Cristopher Martinez Reyes](https://www.linkedin.com/in/jcmartinezreyes/)