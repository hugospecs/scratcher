#!/bin/bash

usage() {
  echo -e "\n📌 Uso:"
  echo "$0 -b                              # Búsqueda general"
  echo "$0 -d <dir> -t oculto              # Archivos ocultos"
  echo "$0 -d <dir> -n <nombre>            # Nombre exacto"
  echo "$0 -d <dir> -k <palabra>           # Palabra en nombre"
  exit 1
}

BUSQUEDA_GENERAL=0
DIR=""
NAME=""
KEYWORD=""
TYPE=""

while [[ $# -gt 0 ]]; do
  case $1 in
    -b) BUSQUEDA_GENERAL=1 ;;
    -d) DIR="$2"; shift ;;
    -n) NAME="$2"; shift ;;
    -k) KEYWORD="$2"; shift ;;
    -t) TYPE="$2"; shift ;;
    *) usage ;;
  esac
  shift
done

# Función de búsqueda general
run_general_search() {
  echo -e "\n🔍 Archivos ocultos:"
  find / -type f -name ".*" 2>/dev/null

  echo -e "\n🔍 Archivos con backup en el nombre:"
  find / -type f -iname "*backup*" 2>/dev/null

  echo -e "\n📋 Archivos de log:"
  find / -type f \( -iname "*.log" -o -iname "*log*" \) 2>/dev/null

  echo -e "\n⚙️ Archivos de configuración:"
  find / -type f \( -iname "*.conf" -o -iname "*.cfg" -o -iname "*config*" \) 2>/dev/null

  echo -e "\n🚨 Archivos con SUID:"
  find / -type f -perm -4000 -exec ls -l {} 2>/dev/null \;

  echo -e "\n🚨 Archivos con GUID:"
  find / -type f -perm -2000 -exec ls -l {} 2>/dev/null \;

  echo -e "\n👤 Archivos del usuario $(whoami) con permisos:"
  find / -type f -user $(whoami) -perm /600 2>/dev/null
}

# Función de búsqueda personalizada
run_specific_search() {
  [[ -z "$DIR" ]] && usage

  echo -e "\n🔎 Ejecutando búsqueda específica en $DIR..."

  if [[ "$TYPE" == "oculto" ]]; then
    find "$DIR" -type f -name ".*"
  fi

  if [[ -n "$NAME" ]]; then
    find "$DIR" -type f -name "$NAME"
  fi

  if [[ -n "$KEYWORD" ]]; then
    find "$DIR" -type f -iname "*$KEYWORD*"
  fi
}

# Lógica principal
if [[ $BUSQUEDA_GENERAL -eq 1 ]]; then
  run_general_search
else
  run_specific_search
fi

