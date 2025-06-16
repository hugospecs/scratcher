#!/bin/bash

usage() {
  echo -e "\n📌 Uso:"
  echo "$0 -b -d <directorio>                     # Búsqueda general"
  echo "$0 -d <dir> [-t oculto] [-n <nombre>] [-k <palabra>] [-e <extensión>] [--rwx-user] [--rwx-group]"
  exit 1
}

BUSQUEDA_GENERAL=0
DIR=""
NAME=""
KEYWORD=""
TYPE=""
EXTENSION=""
RWX_USER=0
RWX_GROUP=0

while [[ $# -gt 0 ]]; do
  case $1 in
    -b) BUSQUEDA_GENERAL=1 ;;
    -d) DIR="$2"; shift ;;
    -n) NAME="$2"; shift ;;
    -k) KEYWORD="$2"; shift ;;
    -t) TYPE="$2"; shift ;;
    -e) EXTENSION="$2"; shift ;;
    --rwx-user) RWX_USER=1 ;;
    --rwx-group) RWX_GROUP=1 ;;
    *) usage ;;
  esac
  shift
done

[[ -z "$DIR" ]] && usage

run_general_search() {
  echo -e "\n🔍 Archivos ocultos:"
  find "$DIR" -type f -name ".*" 2>/dev/null

  echo -e "\n🔍 Archivos con backup en el nombre:"
  find "$DIR" -type f -iname "*backup*" 2>/dev/null

  echo -e "\n📋 Archivos de log:"
  find "$DIR" -type f \( -iname "*.log" -o -iname "*log*" \) 2>/dev/null

  echo -e "\n⚙️ Archivos de configuración:"
  find "$DIR" -type f \( -iname "*.conf" -o -iname "*.cfg" -o -iname "*config*" \) 2>/dev/null

  echo -e "\n🚨 Archivos con SUID:"
  find "$DIR" -type f -perm -4000 -exec ls -l {} \; 2>/dev/null

  echo -e "\n🚨 Archivos con GUID:"
  find "$DIR" -type f -perm -2000 -exec ls -l {} \; 2>/dev/null

  echo -e "\n👤 Archivos del usuario $(whoami) con permisos:"
  find "$DIR" -type f -user $(whoami) -perm /700 2>/dev/null
}

run_specific_search() {
  echo -e "\n🔎 Ejecutando búsqueda específica en $DIR..."

  [[ "$TYPE" == "oculto" ]] && find "$DIR" -type f -name ".*" 2>/dev/null

  [[ -n "$NAME" ]] && find "$DIR" -type f -name "$NAME" 2>/dev/null

  [[ -n "$KEYWORD" ]] && find "$DIR" -type f -iname "*$KEYWORD*" 2>/dev/null

  [[ -n "$EXTENSION" ]] && find "$DIR" -type f -iname "*.$EXTENSION" 2>/dev/null

  if [[ $RWX_USER -eq 1 ]]; then
    echo -e "\n👤 Archivos con permisos rwx para el usuario actual:"
    find "$DIR" -type f -user $(whoami) -perm -700 2>/dev/null
  fi

  if [[ $RWX_GROUP -eq 1 ]]; then
    GROUP=$(id -gn)
    echo -e "\n👥 Archivos con permisos rwx para el grupo '$GROUP':"
    find "$DIR" -type f -group "$GROUP" -perm -070 2>/dev/null
  fi
}

# Lógica principal
if [[ $BUSQUEDA_GENERAL -eq 1 ]]; then
  run_general_search
else
  run_specific_search
fi


