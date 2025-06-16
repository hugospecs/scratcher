#!/bin/bash

usage() {
  echo -e "\n"
  echo "╔══════════════════════════════════════╗"
  echo "║    ▄████████  ▄█    █▄  ███▄▄▄▄      ║"
  echo "║   ███    ███ ███    ███ ███▀▀▀██▄    ║"
  echo "║   ███    █▀  ███    ███ ███   ███    ║"
  echo "║   ███        ███    ███ ███   ███    ║"
  echo "║ ▀███████████ ███    ███ ███   ███    ║"
  echo "║          ███ ███    ███ ███   ███    ║"
  echo "║    ▄█    ███ ███    ███ ███   ███    ║"
  echo "║  ▄████████▀   ▀██████▀   ▀█   █▀     ║"
  echo "║        S C R A T C H E R             ║"
  echo "║    🧠  Hugo Ortega Martin            ║"
  echo "╚══════════════════════════════════════╝"
  echo -e "\n Uso:"
  echo
  echo
  echo "GENERAL SEARCH"
  echo "$0 -b -d <path> -m <f|d|a>"
  echo
  echo "f -> file search mode"
  echo "d -> directory search mode"
  echo "a -> all search mode"
  echo
  echo 
  echo "SPECIFIC SEARCH"
  echo "$0 -d <path> -m <f|d|a> [opciones...]"
  echo
  echo "f -> file search mode"
  echo "d -> directory search mode"
  echo "a -> all search mode"
  echo
  echo
  echo -e "\n File Options..."
  echo "  -t                      hidden files/directories"
  echo "  -n <name>               name"
  echo "  -k <word>               contains word"
  echo "  -e <extension>          file extension"
  echo
  echo -e "\n Perm Options..."
  echo "  --rwx-user              rwx perms for actual user"
  echo "  --rwx-group             rwx perms for actual users group"
  echo "  --user <user>           user"
  echo "  --group <group>         group"
  echo "  --perm <rwx>            specific perms for specific --user"
  echo "  --suid                  SUID file"
  echo "  --sgid                  SGID files"
  exit 1
}


BUSQUEDA_GENERAL=0
DIR=""
NAME=""
KEYWORD=""
TYPE=""
EXTENSION=""
MATCH_TYPE="f"
RWX_USER=0
RWX_GROUP=0
SUID=0
SGID=0
FILTER_USER=""
FILTER_GROUP=""
PERM_STRING=""
PERM_USER=""

# Argument parsing
while [[ $# -gt 0 ]]; do
  case $1 in
    -b) BUSQUEDA_GENERAL=1 ;;
    -d) DIR="$2"; shift ;;
    -n) NAME="$2"; shift ;;
    -k) KEYWORD="$2"; shift ;;
    -t) TYPE="$2"; shift ;;
    -e) EXTENSION="$2"; shift ;;
    -m) MATCH_TYPE="$2"; shift ;;
    --rwx-user) RWX_USER=1 ;;
    --rwx-group) RWX_GROUP=1 ;;
    --user) FILTER_USER="$2"; shift ;;
    --group) FILTER_GROUP="$2"; shift ;;
    --perm) PERM_STRING="$2"; shift ;;
    --suid) SUID=1 ;;
    --sgid) SGID=1 ;;
    *) usage ;;
  esac
  shift
done

[[ -z "$DIR" ]] && usage

build_find_type() {
  case $MATCH_TYPE in
    f) echo "-type f" ;;
    d) echo "-type d" ;;
    a) echo "" ;;
    *) echo "-type f" ;;
  esac
}

run_ls() {
  while IFS= read -r item; do
    ls -la "$item"
  done
}

run_general_search() {
  FIND_TYPE=$(build_find_type)

  echo -e "\n Hidden:"
  find "$DIR" $FIND_TYPE -name ".*" 2>/dev/null | xargs ls -la

  echo -e "\n 'Backup' en el nombre:"
  find "$DIR" $FIND_TYPE -iname "*backup*" 2>/dev/null | xargs ls -la

  echo -e "\n Logs:"
  find "$DIR" $FIND_TYPE \( -iname "*.log" -o -iname "*log*" \) 2>/dev/null | xargs ls -la

  echo -e "\n Config:"
  find "$DIR" $FIND_TYPE \( -iname "*.conf" -o -iname "*.cfg" -o -iname "*config*" \) 2>/dev/null | xargs ls -la

  echo -e "\n🔐 SUID:"
  find "$DIR" -type f -perm -4000 2>/dev/null | xargs ls -la

  echo -e "\n🚨 SGID:"
  find "$DIR" -type f -perm -2000 2>/dev/null | xargs ls -la

  echo -e "\n👤 rwx for $(whoami):"
  find "$DIR" -type f -user $(whoami) -perm -700 2>/dev/null | xargs ls -la
}

run_specific_search() {
  FIND_TYPE=$(build_find_type)

  echo -e "\n Specific Search On ($DIR)..."

  [[ "$TYPE" == "oculto" ]] && find "$DIR" $FIND_TYPE -name ".*" 2>/dev/null | xargs ls -la
  [[ -n "$NAME" ]] && find "$DIR" $FIND_TYPE -name "$NAME" 2>/dev/null | xargs ls -la
  [[ -n "$KEYWORD" ]] && find "$DIR" $FIND_TYPE -iname "*$KEYWORD*" 2>/dev/null | xargs ls -la
  [[ -n "$EXTENSION" ]] && find "$DIR" $FIND_TYPE -iname "*.$EXTENSION" 2>/dev/null | xargs ls -la

  [[ $RWX_USER -eq 1 ]] && find "$DIR" -type f -user $(whoami) -perm -700 2>/dev/null | xargs ls -la
  [[ $RWX_GROUP -eq 1 ]] && find "$DIR" -type f -group $(id -gn) -perm -070 2>/dev/null | xargs ls -la
  [[ -n "$FILTER_USER" ]] && find "$DIR" $FIND_TYPE -user "$FILTER_USER" 2>/dev/null | xargs ls -la
  [[ -n "$FILTER_GROUP" ]] && find "$DIR" $FIND_TYPE -group "$FILTER_GROUP" 2>/dev/null | xargs ls -la
  [[ $SUID -eq 1 ]] && find "$DIR" -type f -perm -4000 2>/dev/null | xargs ls -la
  [[ $SGID -eq 1 ]] && find "$DIR" -type f -perm -2000 2>/dev/null | xargs ls -la

  # 🔐 Búsqueda por permisos personalizados
  if [[ -n "$PERM_STRING" && -n "$FILTER_USER" ]]; then
    case "$PERM_STRING" in
      r)    PERM_BIN=400 ;; w)    PERM_BIN=200 ;;
      x)    PERM_BIN=100 ;;
      rw)   PERM_BIN=600 ;; rx)   PERM_BIN=500 ;;
      wx)   PERM_BIN=300 ;; rwx)  PERM_BIN=700 ;;
      *) echo "❌ Permiso inválido: $PERM_STRING"; exit 1 ;;
    esac
    find "$DIR" $FIND_TYPE -user "$FILTER_USER" -perm -$PERM_BIN 2>/dev/null | xargs ls -la
  fi
}

# Ejecución
if [[ $BUSQUEDA_GENERAL -eq 1 ]]; then
  run_general_search
else
  run_specific_search
fi
