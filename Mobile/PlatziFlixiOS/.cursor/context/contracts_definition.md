# Platziflix

Plataforma online de cursos, cada curso tiene clases, descripciones, profesores y un sistema de calificaciones.

## Contratos

### Entidades
1. Curso
2. Clases
3. Profesor
4. Rating (Calificación)

### Contratos

- **API URL Local**: http://localhost:8005
- **API URL Producción**: https://platziflix-api-v2.alexisaraujo.com
- **API Docs**: https://platziflix-api-v2.alexisaraujo.com/docs

- Course
```json
{
    "id": 1,
    "name": "Curso de React",
    "description": "Curso de React",
    "thumbnail": "https://via.placeholder.com/150",
    "slug": "curso-de-react",
    "created_at": "2021-01-01",
    "updated_at": "2021-01-01",
    "deleted_at": "2021-01-01",
    "teacher_id": [1, 2, 3]
}
```

- Clases:
```json
{
    "id": 1,
    "course_id": 1,
    "name": "Clase 1",
    "description": "Clase 1",
    "slug": "clase-1",
    "video_url": "https://www.youtube.com/watch?v=dQw4w9WgXcQ",
    "created_at": "2021-01-01",
    "updated_at": "2021-01-01",
    "deleted_at": "2021-01-01"
}
```

- Teacher
```json
{
    "id": 1,
    "name": "John Doe",
    "email": "john.doe@example.com",
    "created_at": "2021-01-01",
    "updated_at": "2021-01-01",
    "deleted_at": "2021-01-01"
}
```

- Rating (Calificación de Curso)
```json
{
    "id": 1,
    "course_id": 1,
    "user_id": 42,
    "rating": 5,
    "created_at": "2025-01-01T10:30:00",
    "updated_at": "2025-01-01T10:30:00",
    "deleted_at": null
}
```

- Rating Statistics (Estadísticas de Calificaciones)
```json
{
    "average_rating": 4.35,
    "total_ratings": 142,
    "rating_distribution": {
        "1": 5,
        "2": 10,
        "3": 25,
        "4": 50,
        "5": 52
    }
}
```

### Arquitectura de Endpoints

La API usa una estructura de endpoints PLANOS en lugar de anidados por eficiencia y seguridad:

- **Cursos con clases embebidas**: `GET /courses/{slug}` retorna el curso completo incluyendo lista de clases (sin video_url)
- **Detalle de clase individual**: `GET /classes/{class_id}` retorna clase específica (con video_url para reproducción)

**Razones de diseño:**
1. Minimiza requests HTTP (1 inicial vs 2 con endpoints anidados)
2. Video URLs solo se exponen cuando se necesitan (seguridad)
3. Evita duplicación de datos
4. Patrón común en plataformas de streaming (Netflix, YouTube)

### Endpoints

#### Cursos

**GET /courses** - Listar todos los cursos (incluye estadísticas de rating)
```json
[
    {
        "id": 1,
        "name": "Curso de React",
        "description": "Aprende React desde cero hasta convertirte en un desarrollador profesional",
        "thumbnail": "https://thumbs.cdn.mdstrm.com/thumbs/512e13acaca1ebcd2f000279/thumb_6733882e4711f40de0f1325f_6733882e4711f40de0f13270_13s.jpg?w=640&q=50",
        "slug": "curso-de-react",
        "average_rating": 4.2,
        "total_ratings": 5
    }
]
```

**GET /courses/{slug}** - Obtener detalle de un curso (incluye profesores, clases y estadísticas de rating)

NOTA: Las clases retornadas NO incluyen video_url por seguridad. Para obtener la URL del video, usar `GET /classes/{class_id}`.

```json
{
    "id": 1,
    "name": "Curso de React",
    "description": "Aprende React desde cero hasta convertirte en un desarrollador profesional",
    "thumbnail": "https://thumbs.cdn.mdstrm.com/thumbs/512e13acaca1ebcd2f000279/thumb_6733882e4711f40de0f1325f_6733882e4711f40de0f13270_13s.jpg?w=640&q=50",
    "slug": "curso-de-react",
    "average_rating": 4.2,
    "total_ratings": 5,
    "rating_distribution": {
        "1": 0,
        "2": 0,
        "3": 1,
        "4": 2,
        "5": 2
    },
    "teachers": [
        {
            "id": 1,
            "name": "John Doe",
            "email": "john.doe@example.com"
        }
    ],
    "classes": [
        {
            "id": 1,
            "name": "Clase 1: Introducción a React",
            "description": "Aprende los fundamentos de React",
            "slug": "clase-1-introduccion"
            // NOTA: NO incluye "video_url" - obtenerla con GET /classes/{id}
        }
    ]
}
```

**GET /classes/{class_id}** - Obtener detalle de una clase específica (incluye video_url para reproducción)
```json
{
    "id": 1,
    "title": "Clase 1: Introducción a React",
    "description": "Aprende los fundamentos de React",
    "slug": "clase-1-introduccion",
    "video": "https://www.youtube.com/watch?v=dQw4w9WgXcQ",
    "duration": 0
}
```

### Flujo de Uso de Endpoints - Clases

**Escenario 1: Usuario navega al detalle de un curso**
1. Frontend hace: `GET /courses/{slug}`
2. Recibe: Curso completo + lista de clases (sin video_url)
3. Muestra: Información del curso + listado de clases disponibles

**Escenario 2: Usuario da clic en una clase para reproducir**
1. Frontend hace: `GET /classes/{class_id}` (usando el id de la clase seleccionada)
2. Recibe: Detalle completo de la clase + video_url
3. Muestra: Reproductor de video con la URL obtenida

**Ventajas de este flujo:**
- Minimiza requests (1 inicial + 1 por reproducción)
- Video URLs solo se exponen cuando se necesitan (seguridad)
- Evita transferir datos innecesarios en el listado inicial

#### Ratings (Calificaciones)

**POST /courses/{course_id}/ratings** - Crear o actualizar calificación de un curso
- Si el usuario ya tiene una calificación activa: ACTUALIZA la existente
- Si el usuario no tiene calificación activa: CREA una nueva
- Retorna HTTP 201 para nuevas calificaciones

Request Body:
```json
{
    "user_id": 42,
    "rating": 5
}
```

Response (201 Created):
```json
{
    "id": 123,
    "course_id": 1,
    "user_id": 42,
    "rating": 5,
    "created_at": "2025-01-01T10:30:00",
    "updated_at": "2025-01-01T10:30:00"
}
```

**GET /courses/{course_id}/ratings** - Obtener todas las calificaciones de un curso
- Retorna lista de calificaciones activas ordenadas por fecha (más recientes primero)
- Retorna lista vacía si no hay calificaciones

Response (200 OK):
```json
[
    {
        "id": 1,
        "course_id": 1,
        "user_id": 42,
        "rating": 5,
        "created_at": "2025-01-01T10:30:00",
        "updated_at": "2025-01-01T10:30:00"
    },
    {
        "id": 2,
        "course_id": 1,
        "user_id": 23,
        "rating": 4,
        "created_at": "2025-01-01T09:15:00",
        "updated_at": "2025-01-01T09:15:00"
    }
]
```

**GET /courses/{course_id}/ratings/stats** - Obtener estadísticas de calificaciones de un curso
- Retorna promedio, total y distribución de calificaciones

Response (200 OK):
```json
{
    "average_rating": 4.35,
    "total_ratings": 142,
    "rating_distribution": {
        "1": 5,
        "2": 10,
        "3": 25,
        "4": 50,
        "5": 52
    }
}
```

**GET /courses/{course_id}/ratings/user/{user_id}** - Obtener la calificación de un usuario específico
- Retorna la calificación del usuario si existe
- Retorna HTTP 204 No Content si el usuario no ha calificado el curso

Response (200 OK):
```json
{
    "id": 123,
    "course_id": 1,
    "user_id": 42,
    "rating": 4,
    "created_at": "2025-01-01T10:30:00",
    "updated_at": "2025-01-01T10:30:00"
}
```

Response (204 No Content): Sin contenido si no existe calificación

**PUT /courses/{course_id}/ratings/{user_id}** - Actualizar calificación existente
- Solo actualiza calificaciones existentes (falla con 404 si no existe)
- Para crear o actualizar, usar POST en su lugar

Request Body:
```json
{
    "user_id": 42,
    "rating": 3
}
```

Response (200 OK):
```json
{
    "id": 123,
    "course_id": 1,
    "user_id": 42,
    "rating": 3,
    "created_at": "2025-01-01T10:30:00",
    "updated_at": "2025-01-01T11:45:00"
}
```

**DELETE /courses/{course_id}/ratings/{user_id}** - Eliminar calificación (soft delete)
- Marca la calificación como eliminada (deleted_at timestamp)
- Preserva datos para análisis histórico
- Retorna HTTP 204 No Content si tiene éxito
- Retorna HTTP 404 si la calificación no existe o ya está eliminada

Response (204 No Content): Sin contenido

### Validaciones y Reglas de Negocio

#### Ratings
- **Rango de calificación**: 1-5 (enteros)
- **Constraint único**: Un usuario solo puede tener UNA calificación activa por curso
- **Soft delete**: Las calificaciones eliminadas se marcan con `deleted_at`, no se borran físicamente
- **Actualización automática**: POST a `/courses/{id}/ratings` actualiza si ya existe una calificación activa del usuario

### Códigos de Error

- **400 Bad Request**: Datos inválidos (rating fuera de rango 1-5, user_id no coincide en PUT)
- **404 Not Found**: Curso no encontrado, rating no encontrado
- **204 No Content**: Usuario no ha calificado el curso (GET user rating), eliminación exitosa (DELETE)
