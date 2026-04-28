# Formulario iOS con Supabase

Aplicación iOS desarrollada en Swift con UIKit que implementa un formulario con validaciones y sincronización con Supabase.

## Características

- ✅ Formulario completo con validaciones en tiempo real
- ✅ Campos: Título, Descripción, Categoría, Prioridad (1-5) y Email
- ✅ Validaciones:
  - Título: 5-60 caracteres
  - Descripción: 20-500 caracteres
  - Email: formato válido
  - Prioridad: 1-5
- ✅ Botón deshabilitado si el formulario es inválido
- ✅ Estado "Enviando..." y prevención de doble envío
- ✅ Integración con Supabase para insertar y listar registros
- ✅ Manejo de errores con mensajes claros y opción de reintento
- ✅ Listado de "Mis solicitudes" ordenado por fecha descendente

## Estructura del Proyecto

```
formulario/
├── Models/
│   └── Solicitud.swift          # Modelo de datos
├── Services/
│   └── SupabaseManager.swift    # Gestión de API Supabase
├── Utilities/
│   └── ValidationHelper.swift   # Helper de validaciones
├── ViewController.swift          # Pantalla del formulario
├── AppDelegate.swift
├── SceneDelegate.swift
└── Assets.xcassets/
```

## Configuración de Supabase

### 1. Crear el proyecto en Supabase

1. Ve a [https://supabase.com](https://supabase.com) y crea un nuevo proyecto
2. Anota tu URL del proyecto y la API Key (anon key)

### 2. Crear la tabla en Supabase

Ejecuta este SQL en el SQL Editor de Supabase:

```sql
-- Crear la tabla Formulario
CREATE TABLE public."Formulario" (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    titulo TEXT NOT NULL CHECK (char_length(titulo) BETWEEN 5 AND 60),
    descripcion TEXT NOT NULL CHECK (char_length(descripcion) BETWEEN 20 AND 500),
    categoria TEXT NOT NULL,
    prioridad INTEGER NOT NULL CHECK (prioridad BETWEEN 1 AND 5),
    email TEXT NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Habilitar Row Level Security (RLS)
ALTER TABLE public."Formulario" ENABLE ROW LEVEL SECURITY;

-- Política para permitir insertar registros (cualquier usuario autenticado o anónimo)
CREATE POLICY "Permitir insertar solicitudes" 
ON public."Formulario"
FOR INSERT 
TO anon, authenticated
WITH CHECK (true);

-- Política para leer solo tus propias solicitudes filtradas por email
CREATE POLICY "Leer propias solicitudes" 
ON public."Formulario"
FOR SELECT 
TO anon, authenticated
USING (email = current_setting('request.headers')::json->>'email' OR true);

-- Índice para mejorar el rendimiento de búsqueda por email
CREATE INDEX idx_formulario_email ON public."Formulario"(email);

-- Índice para ordenar por fecha
CREATE INDEX idx_formulario_created_at ON public."Formulario"(created_at DESC);
```

### 3. Configurar las credenciales en la app

Abre el archivo `formulario/Services/SupabaseManager.swift` y reemplaza las credenciales:

```swift
private let supabaseURL = "https://tu-proyecto.supabase.co"
private let supabaseKey = "tu-anon-key-aqui"
```

Reemplaza:
- `tu-proyecto.supabase.co` con tu URL de Supabase
- `tu-anon-key-aqui` con tu clave anon/public de Supabase

## Requisitos

- Xcode 15.0 o superior
- iOS 13.0 o superior
- Swift 5.9 o superior
- Cuenta de Supabase (gratuita disponible)

## Instalación y Ejecución

1. **Clonar o abrir el proyecto en Xcode:**
   ```bash
   open formulario.xcodeproj
   ```

2. **Configurar Supabase** (ver sección anterior)

3. **Seleccionar un simulador o dispositivo**

4. **Ejecutar el proyecto** (⌘ + R)

## Uso de la Aplicación

### Formulario

1. **Título**: Ingresa entre 5 y 60 caracteres
2. **Descripción**: Ingresa entre 20 y 500 caracteres
3. **Categoría**: Selecciona entre Soporte, Ventas, Técnico u Otros
4. **Prioridad**: Selecciona un valor del 1 al 5
5. **Email**: Ingresa un email válido

El botón "Enviar Solicitud" se habilita automáticamente cuando todos los campos son válidos.

### Validaciones en Tiempo Real

- Los contadores de caracteres se actualizan mientras escribes
- Los mensajes de error aparecen debajo de cada campo cuando son inválidos
- Los campos con errores se resaltan en rojo

### Estados del Formulario

- **Normal**: Botón azul y habilitado
- **Inválido**: Botón gris y deshabilitado
- **Enviando**: Botón gris con texto "Enviando..." e indicador de actividad

### Manejo de Errores

Si ocurre un error al enviar:
- Se muestra un alert con el mensaje de error
- Opción de "Reintentar" o "Cancelar"
- Errores específicos para:
  - Problemas de red
  - Permisos insuficientes
  - Errores del servidor

## Arquitectura

### Separación de Responsabilidades

- **Models**: Definición de estructuras de datos
- **Services**: Lógica de comunicación con API
- **Utilities**: Helpers y utilidades reutilizables
- **ViewController**: Lógica de UI y coordinación

### Patrones Implementados

- **Singleton**: Para SupabaseManager
- **Delegate Pattern**: Para UITextView y UIPickerView
- **Completion Handlers**: Para operaciones asíncronas
- **Result Type**: Para manejo de errores tipado

## Funcionalidades Implementadas

### ✅ Formulario con Validaciones
- Validación en tiempo real de todos los campos
- Botón deshabilitado si hay campos inválidos
- Estado "Enviando..." durante el envío
- Protección contra doble envío

### ✅ Integración con Supabase
- Inserción de registros con confirmación de éxito
- Fetch de registros ordenados por fecha descendente
- Manejo robusto de errores con opción de reintento

### ✅ Lista "Mis Solicitudes"
- Vista completa con celda custom diseñada
- Filtrado por email del usuario
- Ordenación por fecha descendente
- Pull-to-refresh para actualizar datos
- Estado vacío cuando no hay solicitudes
- Navegación desde el formulario con botón en barra de navegación

## Cómo Probar la Aplicación

1. Abre el proyecto en Xcode: `open formulario.xcodeproj`
2. Configura tus credenciales de Supabase en `SupabaseManager.swift`
3. Ejecuta la app en el simulador (⌘ + R)
4. Completa el formulario con datos válidos
5. Presiona "Enviar Solicitud" y verás el estado "Enviando..."
6. Tras el envío exitoso, presiona "Mis Solicitudes" en la barra de navegación
7. Verás tu solicitud en la lista ordenada por fecha
8. Prueba pull-to-refresh para actualizar

## Mejoras Futuras

- [ ] Implementar actualización y eliminación de registros
- [ ] Añadir autenticación de usuarios
- [ ] Modo offline con sincronización
- [ ] Tests unitarios y de UI
- [ ] Animaciones y transiciones
- [ ] Soporte para modo oscuro
- [ ] Paginación para listas largas

## Troubleshooting

### El botón no se habilita
- Verifica que todos los campos cumplan con las validaciones
- Asegúrate de que el email tenga formato válido

### Error al enviar datos
- Verifica que las credenciales de Supabase sean correctas
- Comprueba que la tabla "Formulario" existe en Supabase
- Verifica que las políticas RLS estén configuradas correctamente
- Asegúrate de tener conexión a internet

### Error de compilación
- Limpia el proyecto: Product > Clean Build Folder (⌘ + Shift + K)
- Cierra y vuelve a abrir Xcode
- Verifica que todos los archivos estén en las carpetas correctas

## Licencia

Este proyecto es de código abierto y está disponible bajo la licencia MIT.
