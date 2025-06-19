# Fishpot Backend

Este es el repositorio del **backend** de Fishpot, una aplicación web colaborativa diseñada para conectar a pescadores de todos los niveles. Se encarga de gestionar toda la lógica de negocio, la persistencia de datos y la interacción con la base de datos para potenciar el mapa interactivo y las funcionalidades compartidas de la plataforma.

---

## 🎯 Objetivo

El objetivo principal de este backend es proveer una API robusta y escalable que permita a Fishpot funcionar de manera eficiente, gestionando la información de spots de pesca, usuarios, especies, técnicas y comentarios. Buscamos ofrecer una experiencia fluida y confiable a los usuarios, garantizando la integridad y disponibilidad de los datos.

---

## 👥 Participantes

- Iñaki Urbizu
- Augusto Kopach

---

## 🧩 Tecnologías Utilizadas

Este backend está construido con un stack moderno y eficiente:

* **Framework:** **NestJS** (un framework progresivo de Node.js para construir aplicaciones del lado del servidor escalables y eficientes).
* **Base de datos:** **PostgreSQL** (sistema de gestión de bases de datos relacional robusto y de código abierto).
* **ORM (Object-Relational Mapper):** **Sequelize** (facilita la interacción con la base de datos de manera programática).
* **Control de versiones:** **Git**
* **Contenedores:** **Docker** (para el empaquetado y despliegue consistente de la aplicación y la base de datos).

---

## 🧪 Funcionalidades Cubiertas por el Backend

El backend soporta las siguientes funcionalidades clave de Fishpot:

* **Autenticación y Autorización:** Integración con Google para el manejo de usuarios y roles (Pescador, Moderador).
* **Gestión de Spots de Pesca:** Creación, lectura, actualización y eliminación de spots, incluyendo sus coordenadas geográficas, especies, carnadas y técnicas asociadas.
* **Moderación de Contenido:** Lógica para la aprobación o rechazo de spots sugeridos por los usuarios.
* **Gestión de Comentarios:** Almacenamiento y recuperación de comentarios y experiencias asociadas a cada spot.
* **Filtrado y Búsqueda:** Funcionalidades para filtrar spots por especie, técnica o ubicación.
* **Perfiles de Usuario:** Gestión de datos editables para cada perfil de usuario.
* **Reportes:** Manejo de reportes de spots inapropiados.

---

## 🚀 Cómo Correr el Proyecto (Backend)

Sigue estos pasos para levantar el backend de Fishpot en tu entorno local:

1.  **Clonar el Repositorio:**
    ```bash
    git clone https://github.com/TpFishSpot/FishSpot_Backend.git
    ```

2.  **Acceder al Directorio del Backend:**
    ```bash
    cd fishpot-backend
    ```

3.  **Configurar Variables de Entorno:**
    Crea un archivo `.env` en la raíz del proyecto (donde está `package.json`). Este archivo contendrá variables de entorno necesarias para la conexión a la base de datos y otras configuraciones. Un ejemplo básico podría ser:


4.  **Iniciar la Base de Datos con Docker:**
    Asegúrate de tener Docker instalado y ejecutándose. Usa el siguiente comando para iniciar un contenedor de PostgreSQL con un **volumen persistente** para tus datos. Esto asegura que tus datos no se pierdan si el contenedor es eliminado.
    ```bash
    docker run --name fishpot_db_container -p 5432:5432 -v /ruta/a/tu/carpeta/dbData:/var/lib/postgresql/data postgres
    ```
    * Reemplaza `/ruta/a/tu/carpeta/dbData` con la ruta absoluta a la carpeta donde quieres que se guarden los datos de tu base de datos en tu máquina local (ej: `/Users/rully/Desktop/practicas/FishSpot/dbData`).

5.  **Instalar Dependencias:**
    ```bash
    npm install
    ```
7.  **Iniciar el Servidor en Entorno de Desarrollo:**
    ```bash
    npm run start:dev
    ```
    El backend debería estar ahora corriendo y escuchando en el puerto configurado (por defecto, `3000`).

---

Este proyecto se distribuye bajo licencia MIT. Ver archivo LICENSE para más detalles.