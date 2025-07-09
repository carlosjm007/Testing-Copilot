#!/bin/bash

# Verifica si se proporcionó un nombre de proyecto
if [ -z "$1" ]; then
  echo "Por favor, proporciona un nombre para el proyecto."
  echo "Uso: $0 <NombreDelProyecto>"
  exit 1
fi

# Asigna el nombre del proyecto a una variable
PROJECT_NAME=$1

# Crea un proyecto de minimal api de .net
echo "CREANDO PROYECTO DE MINIMAL API DE .NET"
dotnet new webapi -n "$PROJECT_NAME"

# Crea un proyecto de pruebas para el proyecto de minimal api de .net
echo "CREANDO PROYECTO DE TESTS PARA MINIMAL API DE .NET"
dotnet new xunit -n "$PROJECT_NAME.Tests"

# Asocia los dos proyectos
echo "ASOCIANDO PROYECTOS"
dotnet add "$PROJECT_NAME.Tests/$PROJECT_NAME.Tests.csproj" reference "$PROJECT_NAME/$PROJECT_NAME.csproj"

# Crea un archivo de solución
echo "CREANDO SOLUCIÓN"
dotnet new sln -n "${PROJECT_NAME}Solution"

# Agrega ambos proyectos a la solución
echo "AGREGANDO PROYECTOS A LA SOLUCIÓN"
dotnet sln "${PROJECT_NAME}Solution.sln" add "$PROJECT_NAME/$PROJECT_NAME.csproj"
dotnet sln "${PROJECT_NAME}Solution.sln" add "$PROJECT_NAME.Tests/$PROJECT_NAME.Tests.csproj"

# Agrega los paquetes necesarios para el proyecto de tests minimal api de .net
echo "AGREGANDO PAQUETES NECESARIOS PARA EL PROYECTO DE TESTS"
dotnet add "$PROJECT_NAME.Tests/$PROJECT_NAME.Tests.csproj" package Microsoft.AspNetCore.Mvc.Testing
dotnet add "$PROJECT_NAME.Tests/$PROJECT_NAME.Tests.csproj" package Moq
dotnet add "$PROJECT_NAME.Tests/$PROJECT_NAME.Tests.csproj" package MiniValidation

# Agrega un archivo de Docker en el proyecto de minimal api de .net
echo "CREANDO ARCHIVO DOCKERFILE"
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

echo "PROYECTO $PROJECT_NAME CREADO EXITOSAMENTE"