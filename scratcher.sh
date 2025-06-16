#!/bin/bash

usage() {
  echo "Uso: $0 -d <directorio> [-t <tipo>] [-n <nombre>] [-k <palabra>] [--audit]"
  echo "  -d <directorio>   Directorio raíz desde donde buscar"
  echo "  -t <tipo>         Tipo de archivo (f = archivo, d = directorio, l = enlace simbólico, etc.)"
  echo "  -n <nombre>       Nombre exacto del archivo"
  echo "  -k <palabra>      Palabra contenida en el nombre del archivo"
  echo "  --audit           Activa búsqueda de archivos críticos y ocultos"
  exit 1
}

AUDIT_MODE=0
DIR=""
TYPE=""
NAME=""
KEYWORD=""

while [[ $# -gt 0 ]]; do
  case $1 in
    -d) DIR="$2"; shift ;;
    -t) TYPE="$2"; shift ;;
    -n) NAME="$2"; shift ;;
    -k) KEYWORD="$2"; shift ;;
    --audit) AUDIT_MODE=1 ;;
    *) usage ;;
  esac
  shift
done

[[ -z "$DIR" ]] && usage

# Búsqueda general con parámetros
echo "🔎 Ejecutando búsqueda..."
CMD="find \"$DIR\""
[[ -n "$TYPE" ]] && CMD+=" -type $TYPE"
[[ -n "$NAME" ]] && CMD+=" -name \"$NAME\""
[[ -n "$KEYWORD" ]] && CMD+=" -iname \"*$KEYWORD*\""

eval $CMD

# Modo auditoría
if [[ $AUDIT_MODE -eq 1 ]]; then
  echo -e "\n⚠️  Modo auditoría activado: buscando archivos críticos u ocultos..."

  echo -e "\n📁 Archivos ocultos:"
  find "$DIR" -type f -name ".*"

  echo -e "\n🔐 Claves privadas y archivos sensibles:"
  find "$DIR" -type f \( -iname "*id_rsa*" -o -iname "*.pem" -o -iname "*.key" \)

  echo -e "\n📚 Archivos de configuración y contraseñas:"
  find "$DIR" -type f \( -iname "*.conf" -o -iname "*.ini" -o -iname "*.yml" -o -iname ".bash_history" \)

  echo -e "\n🚨 Archivos con bit SUID/SGID:"
  find "$DIR" -type f \( -perm -4000 -o -perm -2000 \) -exec ls -l {} \;
fi
