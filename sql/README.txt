===================================================================
TRABAJO FINAL INTEGRADOR - BASES DE DATOS I (UTN)
SCRIPTS SQL

Autores: Diana Falla, Claudio Fiorito, Jennifer Franco, Jonathan Franco
===================================================================

Este directorio contiene todos los scripts SQL necesarios para crear, 
poblar y probar la base de datos "gestion_veterinaria".

-------------------------------------------------
ORDEN DE EJECUCIÓN (SETUP DE LA BASE DE DATOS)
-------------------------------------------------
Para recrear la base de datos desde cero, ejecute los scripts 
en el siguiente orden:

1. 01_esquema.sql
   - Propósito: Crea todas las tablas y sus constraints (PK, FK, CHECK).

2. 02_catalogos.sql
   - Propósito: Inserta los datos maestros en tablas como 'provincia', 'especie', 'raza'.

3. 03_carga_masiva.sql
   - Propósito: Genera y carga los 35.000+ registros en las tablas principales.
   - (!) NOTA: La ejecución de este script puede tardar varios segundos.

4. 04_indices.sql
   - Propósito: Agrega los índices para optimizar las consultas (Etapa 3).

5. 06_vistas.sql
   - Propósito: Crea las vistas de reporte (Etapa 3) y de seguridad (Etapa 4).

6. 07_seguridad.sql
   - Propósito: Crea el usuario 'usuario_consulta' y le otorga permisos (Etapa 4).

7. 08_transacciones.sql
   - Propósito: Crea el procedimiento almacenado para el manejo de deadlocks (Etapa 5).


-------------------------------------------------
SCRIPTS DE CONSULTA Y PRUEBA
-------------------------------------------------
Estos scripts no son parte del setup, sino que contienen las 
consultas y pruebas utilizadas en el informe. Se ejecutan 
manualmente *después* de que la base de datos está creada y poblada.

* 05_consultas.sql
  - Contiene: Las 4 consultas de la Etapa 3 y las pruebas de EXPLAIN.

* 09_concurrencia_guiada.sql
  - Contiene: Los scripts de prueba para simular deadlocks y 
    verificar los niveles de aislamiento (Etapa 5).