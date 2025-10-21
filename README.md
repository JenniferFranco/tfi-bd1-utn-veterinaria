# Trabajo Final Integrador - Bases de Datos I (Gestión Veterinaria)

Este repositorio contiene el desarrollo del Trabajo Final Integrador (TFI) de la materia **Bases de Datos I** de la Tecnicatura Universitaria en Programación (UTN).

## 📌 Descripción

El proyecto consiste en el diseño, implementación y prueba de una base de datos relacional para gestionar la operatoria de una **clínica veterinaria**. Se aplican los conceptos fundamentales del modelado de datos, definición de restricciones, carga masiva de información, consultas avanzadas, seguridad y manejo de concurrencia, utilizando **MySQL** como sistema gestor de base de datos.

## 🛠️ Contenido del Repositorio

* **Informe Final (PDF):** Documento que detalla cada una de las 5 etapas del proyecto, incluyendo:
    * Introducción.
    * **Etapa 1:** Diagrama Entidad-Relación (DER), explicación de entidades, justificación de la normalización y detalle de las `constraints` implementadas.
    * **Etapa 2:** Descripción conceptual de la estrategia de carga masiva y pruebas de consistencia.
    * **Etapa 3:** Consultas avanzadas (JOIN, GROUP BY/HAVING, Subconsultas), creación de vistas y análisis de rendimiento con/sin índices.
    * **Etapa 4:** Creación de usuarios con privilegios mínimos, vistas de seguridad y pruebas de integridad/anti-inyección.
    * **Etapa 5:** Simulación de *deadlocks*, implementación de transacciones con *retry* (procedimiento almacenado) y comparación de niveles de aislamiento.
    * **Anexo IA:** Registro de las interacciones con herramientas de Inteligencia Artificial utilizadas como apoyo pedagógico.
* **Scripts SQL:**
    * `01_creacion_tablas.sql`: Script para crear la estructura completa de la base de datos, incluyendo tablas y todas las `constraints` (PK, FK, UNIQUE, CHECK).
    * `02_carga_masiva.sql`: Script optimizado (`WITH RECURSIVE`) para generar y cargar un volumen significativo de datos (configurable, ej., 35,000 mascotas) respetando la integridad referencial.
    * `03_consultas_avanzadas.sql`: Scripts de las consultas complejas, la creación de la vista y las pruebas de rendimiento.
    * `04_seguridad.sql`: Scripts para la creación del usuario, asignación de permisos y creación de vistas de seguridad.
    * `05_concurrencia.sql`: Scripts utilizados para la simulación de *deadlocks*, la creación del procedimiento almacenado transaccional y la comparación de niveles de aislamiento.
* **Diagrama Entidad-Relación:** Imagen (`.png`) del DER final.

## 👥 Autores

* Jennifer Franco (`jennyfranco31.jf@gmail.com`)
* Jonathan Franco (`nahuelfranco7@icloud.com`)
* Claudio Fiorito (`Claudio80.cf@gmail.com`)
* Diana Falla (`diana.falla.cba@gmail.com`)


## 🎓 Contexto Académico

* **Universidad:** Universidad Tecnológica Nacional (UTN)
* **Carrera:** Tecnicatura Universitaria en Programación
* **Materia:** Bases de Datos I
* **Docente Titular:** Sergio Neira
* **Docente Tutor:** Diego Lobos

## 🔗 Enlaces

* **Video Demostrativo (YouTube):**
* https://youtu.be/Slymx88_xrc 

* **Software Utilizado:**
    * [MySQL](https://www.mysql.com/)
    * [MySQL Workbench](https://www.mysql.com/products/workbench/)
* **Software Utilizado:**
    * [MySQL](https://www.mysql.com/)
    * [MySQL Workbench](https://www.mysql.com/products/workbench/)
