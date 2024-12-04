#!/bin/bash

# Eliminar cualquier versión anterior de Docker
sudo apt-get remove -y docker docker-engine docker.io

# Actualizar la base de datos de paquetes
sudo apt-get update

# Instalar los paquetes necesarios
sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common

# Agregar la clave GPG oficial de Docker
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

# Agregar el repositorio APT de Docker
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Actualizar la base de datos de paquetes con los paquetes de Docker
sudo apt-get update

# Actualizar los paquetes del sistema
sudo apt-get upgrade -y

# Instalar Docker
sudo apt-get install -y docker-ce=5:24.0.5-1~ubuntu.22.04~jammy docker-ce-cli=5:24.0.5-1~ubuntu.22.04~jammy containerd.io docker-ce-rootless-extras docker-buildx-plugin

# Confirmar la instalación de Docker
if docker --version; then
    echo "Docker instalado correctamente."
else
    echo "Error al instalar Docker."
    exit 1
fi

# Preguntar al usuario qué versión de Docker Compose quiere instalar
echo "¿Qué versión de Docker Compose quieres instalar?"
echo "1. Versión 1.29.2 (Webpad)"
echo "2. Versión 2.20.3 (Otras aplicaciones)"
read -p "Ingresa el numero para seleccionar la version (1 o 2): " version

# Instalar Docker Compose según la elección del usuario
if [ "$version" == "1" ]; then
    sudo curl -SL https://github.com/docker/compose/releases/download/1.29.2/docker-compose-linux-x86_64 -o /usr/local/bin/docker-compose
elif [ "$version" == "2" ]; then
    sudo curl -SL https://github.com/docker/compose/releases/download/v2.20.3/docker-compose-linux-x86_64 -o /usr/local/bin/docker-compose
else
    echo "Opción inválida. Abortando instalación."
    exit 1
fi

# Asignar permisos a Docker Compose
sudo chmod a+x /usr/local/bin/docker-compose

# Confirmar la instalación de Docker Compose
if docker-compose --version; then
    echo "Docker Compose instalado correctamente."
else
    echo "Error al instalar Docker Compose."
    exit 1
fi

# Agregar el usuario al grupo de docker
sudo usermod -a -G docker mituser
sudo gpasswd -a mituser docker

# Eliminar apparmor
sudo apt-get purge --auto-remove -y apparmor

# Iniciar el servicio de Docker
sudo systemctl start docker

# Limpiar el sistema de Docker
sudo docker system prune --all --volumes -f

# Habilitar el servicio de Docker para que se inicie al arrancar el sistema
sudo systemctl enable docker

# Mensaje de confirmación
echo "Docker y Docker Compose se han instalado correctamente."

# Cuenta regresiva antes de reiniciar
echo "El servidor se reiniciará en 10 segundos para aplicar los cambios."
for i in {10..1}; do
    echo "$i..."
    sleep 1
done

# Reiniciar el sistema
sudo reboot