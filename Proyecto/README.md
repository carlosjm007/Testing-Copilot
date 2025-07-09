# Proyecto: Generador de Minimal API en .NET

Este proyecto tiene como objetivo automatizar la creación de una solución en .NET que incluye una Minimal API, un proyecto de pruebas unitarias y un archivo Dockerfile para facilitar su despliegue. Todo esto se realiza mediante un script llamado `generador.sh`.

## Estructura del Proyecto

La carpeta `Proyecto` contiene los siguientes elementos principales:

- **`generador.sh`**: Script Bash que automatiza la creación de la solución y los proyectos asociados.
- **`ProyectoCopilot/`**: Carpeta que contendrá el proyecto de Minimal API generado.
- **`ProyectoCopilot.Tests/`**: Carpeta que contendrá el proyecto de pruebas unitarias generado.
- **`Dockerfile`**: Archivo Docker que se genera automáticamente para construir y ejecutar la aplicación.

## Uso del Script `generador.sh`

El archivo `generador.sh` es un script que automatiza la creación de una solución en .NET con los siguientes pasos:

### 1. Verificación del Nombre del Proyecto
El script verifica si se ha proporcionado un nombre para el proyecto. Si no se proporciona, muestra un mensaje de uso y termina la ejecución.

```bash
if [ -z "$1" ]; then
  echo "Por favor, proporciona un nombre para el proyecto."
  echo "Uso: $0 <NombreDelProyecto>"
  exit 1
fi
```

### 2. Creación del Proyecto de Minimal API
Se genera un proyecto de Minimal API utilizando el comando dotnet new webapi.

```bash
dotnet new webapi -n "$PROJECT_NAME"
```

### 3. Creación del Proyecto de Pruebas Unitarias
Se genera un proyecto de pruebas unitarias con xUnit utilizando el comando dotnet new xunit.

```bash
dotnet new xunit -n "$PROJECT_NAME.Tests"
```

### 4. Asociación de Proyectos
El script asocia el proyecto de pruebas unitarias con el proyecto de Minimal API mediante una referencia.

```bash
dotnet add "$PROJECT_NAME.Tests/$PROJECT_NAME.Tests.csproj" reference "$PROJECT_NAME/$PROJECT_NAME.csproj"
```

### 5. Creación de la Solución
Se crea una solución en .NET para agrupar ambos proyectos.

```bash
dotnet new sln -n "${PROJECT_NAME}Solution"
```

### 6. Adición de Proyectos a la Solución
Ambos proyectos (Minimal API y pruebas unitarias) se agregan a la solución.

```bash
dotnet sln "${PROJECT_NAME}Solution.sln" add "$PROJECT_NAME/$PROJECT_NAME.csproj"
dotnet sln "${PROJECT_NAME}Solution.sln" add "$PROJECT_NAME.Tests/$PROJECT_NAME.Tests.csproj"
```

### 7. Instalación de Paquetes para Pruebas
Se instalan paquetes necesarios para realizar pruebas en el proyecto de pruebas unitarias.

```bash
dotnet add "$PROJECT_NAME.Tests/$PROJECT_NAME.Tests.csproj" package Microsoft.AspNetCore.Mvc.Testing
dotnet add "$PROJECT_NAME.Tests/$PROJECT_NAME.Tests.csproj" package Moq
dotnet add "$PROJECT_NAME.Tests/$PROJECT_NAME.Tests.csproj" package MiniValidation
```

### 8. Generación del Archivo Dockerfile
Se genera un archivo Dockerfile que permite construir y ejecutar la aplicación en un contenedor Docker.

```bash
cat <<EOF > Dockerfile
# Use the official .NET SDK image as build stage
FROM mcr.microsoft.com/dotnet/sdk:9.0 AS build
WORKDIR /app

# Copy the project files and restore dependencies
COPY *.csproj ./
RUN dotnet restore

# Copy the rest of the application code
COPY . ./

# Build the application
RUN dotnet publish -c Release -o out

# Use the official ASP.NET Core runtime image as a runtime stage
FROM mcr.microsoft.com/dotnet/aspnet:9.0
WORKDIR /app

# Copy the built application from the build stage
COPY --from=build /app/out .

# Expose the port the app runs on
EXPOSE 80

# Run the application
ENTRYPOINT ["dotnet", "$PROJECT_NAME.dll"]
EOF
```

### 9. Mensaje de Éxito
Finalmente, el script muestra un mensaje indicando que el proyecto se ha creado exitosamente.

```bash
echo "PROYECTO $PROJECT_NAME CREADO EXITOSAMENTE"
```

## Cómo Ejecutar el Script
### 1. Asegúrate de tener instalado el SDK de .NET y Docker en tu sistema.
### 2. Navega a la carpeta `Proyecto`.
### 3. Ejecuta el script proporcionando un nombre para el proyecto:

```bash
bash [generador.sh](http://_vscodecontentref_/0) MiProyecto
```
Esto generará una solución con los proyectos y el archivo Dockerfile listos para usar.

Notas
El archivo `Dockerfile` está configurado para usar imágenes oficiales de .NET SDK y ASP.NET Core Runtime.
Puedes personalizar el script para agregar más configuraciones o paquetes según tus necesidades.