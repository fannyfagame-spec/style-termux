#!/usr/bin/bash
# tools.sh — Toolkit by FannyFa (with logging)
# Semua hasil disimpan ke: /sdcard/script/projek/fa-mux/.object/tools/log.txt

# 🎨 warna
RED='\033[1;31m'; GREEN='\033[1;32m'; YELLOW='\033[1;33m'
BLUE='\033[1;34m'; MAGENTA='\033[1;35m'; CYAN='\033[1;36m'
WHITE='\033[1;37m'; NC='\033[0m'

# lokasi log
LOGFILE="/sdcard/script/projek/fa-mux/.object/tools/log.txt"
mkdir -p "$(dirname "$LOGFILE")" 2>/dev/null || true

# helper: append header to log
log_header() {
  local action="$1"
  local target="$2"
  {
    printf '=%.0s' {1..80}
    printf "\n[%s] ACTION: %s\nTARGET: %s\n\n" "$(date '+%Y-%m-%d %H:%M:%S')" "$action" "$target"
  } >> "$LOGFILE"
}

# helper: append footer to log
log_footer() {
  {
    printf "\n\n"
  } >> "$LOGFILE"
}

clear_log() {
  > "$LOG_FILE"
  clear; banner
  echo -e "${GREEN}🧹 Log berhasil dikosongkan!${NC}"
  sleep 1.5
}

lihat_log() {
  clear; banner
  echo -e "${MAGENTA}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo -e "${YELLOW}📜 LOG HASIL AKTIVITAS${NC}"
  echo -e "${MAGENTA}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo
  if [[ -s "$LOG_FILE" ]]; then
    cat "$LOG_FILE"
  else
    echo -e "${RED}📂 Log kosong.${NC}"
  fi
  echo
  read -n 1 -s -r -p "Tekan apapun untuk kembali ke menu..."
}

# banner
banner() {
  clear
  echo -e "${CYAN}"
  cat << "EOF"
   ██▓     ██▓ ███▄    █  █    ██  ▒██   ██▒▒██   ██▒
  ▓██▒    ▓██▒ ██ ▀█   █  ██  ▓██▒ ▒▒ █ █ ▒░▒▒ █ █ ▒░
  ▒██░    ▒██▒▓██  ▀█ ██▒▓██  ▒██░ ░░  █   ░░  █   ░ 
  ▒██░    ░██░▓██▒  ▐▌██▒▓▓█  ░██░  ░ █ █ ▒  ░ █ █ ▒  
  ░██████▒░██░▒██░   ▓██░▒▒█████▓  ▒██▒ ▒██▒▒██▒ ▒██▒ 
  ░ ▒░▓  ░░▓  ░ ▒░   ▒ ▒ ░▒▓▒ ▒ ▒  ▒▒ ░ ░▓ ░▒▒ ░ ░▓ ░ 
  ░ ░ ▒  ░ ▒ ░░ ░░   ░ ▒░░░▒░ ░ ░  ░░   ░▒ ░░░   ░▒ ░ 
    ░ ░    ▒ ░   ░   ░ ░  ░░░ ░ ░   ░    ░   ░    ░   
      ░  ░ ░           ░    ░       ░    ░   ░    ░   
                                                            
              リナックス | FANNYFA DEVELOPER
EOF
  echo -e "${MAGENTA}──────────────────────────────────────────────${NC}"
  echo -e "${WHITE}⚡ ${CYAN}Secure${WHITE} • ${GREEN}Fast${WHITE} • ${RED}Custom${WHITE} | Powered by ${YELLOW}FannyFa${NC}"
  echo -e "${MAGENTA}──────────────────────────────────────────────${NC}\n"
}

# pretty print to stdout (and return raw json)
pretty_print() {
  local json="$1"
  if command -v jq >/dev/null 2>&1; then
    echo "$json" | jq
  else
    echo "$json"
  fi
}

# ===== [1] cekip_case (ipinfo) =====
cekip_case() {
  clear; banner
  read -p "🌐 Masukkan IP target: " ip
  [[ -z "$ip" ]] && { echo -e "${RED}❌ IP tidak boleh kosong${NC}"; read -p "Enter untuk kembali..."; return; }

  echo -e "${YELLOW}🔎 Mengecek IP info...${NC}"
  sleep 1
  if command -v curl >/dev/null 2>&1; then
    data=$(curl -s --max-time 8 "https://ipinfo.io/${ip}/json")
  else
    data=$(wget -qO- --timeout=8 "https://ipinfo.io/${ip}/json" 2>/dev/null || echo "")
  fi

  if [[ -z "$data" ]]; then
    echo -e "${RED}❌ Tidak dapat mengambil data.${NC}"
    # log failure
    log_header "cekip" "$ip"
    printf "ERROR: failed to fetch ipinfo data\n" >> "$LOGFILE"
    log_footer
    read -p "Enter untuk kembali..."
    return
  fi

  echo -e "\n${CYAN}📡 HASIL IPINFO:${NC}"
  pretty_print "$data"

  # save to log: header + raw JSON + short summary
  log_header "cekip" "$ip"
  printf "RAW_JSON:\n" >> "$LOGFILE"
  printf "%s\n" "$data" >> "$LOGFILE"
  printf "\nSUMMARY:\n" >> "$LOGFILE"
  if command -v jq >/dev/null 2>&1; then
    echo "$data" | jq -r '"IP: \(.ip // "-")", "Hostname: \(.hostname // "-")", "City: \(.city // "-")", "Region: \(.region // "-")", "Country: \(.country // "-")", "Org: \(.org // "-")"' \
      | sed 's/^/ - /' >> "$LOGFILE"
  else
    echo " - (no jq) raw JSON above" >> "$LOGFILE"
  fi
  log_footer

  read -p "Tekan Enter untuk kembali ke menu..."
}

# ===== [2] cekprovider_case (apilayer number_verification) =====
cekprovider_case() {
  clear; banner
  read -p "📱 Masukkan nomor (contoh: 60177769600): " num
  [[ -z "$num" ]] && { echo -e "${RED}❌ Nomor kosong.${NC}"; read -p "Enter untuk kembali..."; return; }

  API_KEY="NsYy5vNmoHcVQSAA0L3VtPMHrWSDowEz"
  URL="https://api.apilayer.com/number_verification/validate?number=$num"

  echo -e "${YELLOW}🔎 Mengecek provider...${NC}"
  sleep 1
  if command -v curl >/dev/null 2>&1; then
    res=$(curl -s -H "apikey: $API_KEY" "$URL")
  else
    res=$(wget -qO- --timeout=8 --header="apikey: $API_KEY" "$URL" 2>/dev/null || echo "")
  fi

  if [[ -z "$res" ]]; then
    echo -e "${RED}❌ Gagal mengambil data.${NC}"
    log_header "cekprovider" "$num"
    printf "ERROR: failed to fetch provider data\n" >> "$LOGFILE"
    log_footer
    read -p "Enter untuk kembali..."
    return
  fi

  echo -e "\n${CYAN}📶 INFORMASI NOMOR:${NC}"
  pretty_print "$res"

  # log raw + summary
  log_header "cekprovider" "$num"
  printf "RAW_JSON:\n" >> "$LOGFILE"
  printf "%s\n" "$res" >> "$LOGFILE"
  printf "\nSUMMARY:\n" >> "$LOGFILE"
  if command -v jq >/dev/null 2>&1; then
    echo "$res" | jq -r '"Valid: \(.valid // "-")", "Country: \(.country_name // "-")", "Carrier: \(.carrier // "-")", "Location: \(.location // "-")", "Line type: \(.line_type // "-")"' \
      | sed 's/^/ - /' >> "$LOGFILE"
  else
    echo " - (no jq) raw JSON above" >> "$LOGFILE"
  fi
  log_footer

  read -p "Tekan Enter untuk kembali ke menu..."
}

# ===== [3] mencari_case (premium) =====
mencari_case() {
  clear; banner
  read -p "Masukkan nomor target (contoh: 628123456789): " q
  [[ -z "$q" ]] && { echo -e "${RED}Nomor kosong.${NC}"; read -p "Enter untuk kembali..."; return; }

  isPremium=true
  if [[ "$isPremium" != "true" ]]; then
    echo -e "${RED}❌ Hanya untuk pengguna premium.${NC}"
    read -p "Enter untuk kembali..."
    return
  fi

  echo -e "${YELLOW}⚙️  Sedang memproses pencarian...${NC}"
  sleep 1

  token="8263204017:FGg8JBEa"
  url="https://leakosintapi.com/"
  limit=100
  lang="id"

  # build json (requires jq)
  if ! command -v jq >/dev/null 2>&1; then
    echo -e "${RED}❌ jq diperlukan untuk operasi ini. Silakan install jq dulu.${NC}"
    read -p "Enter untuk kembali..."
    return
  fi

  json_data=$(jq -n \
    --arg token "$token" \
    --arg request "$q" \
    --argjson limit "$limit" \
    --arg lang "$lang" \
    '{token:$token, request:$request, limit:$limit, lang:$lang}')

  response=$(curl -s -X POST "$url" \
    -H "Content-Type: application/json" \
    -d "$json_data" \
    -w "\n%{http_code}" --max-time 15)

  body=$(echo "$response" | sed '$d')
  status_code=$(echo "$response" | tail -n1)

  echo "Response Status: $status_code"

  if [[ "$status_code" != "200" ]]; then
    echo -e "${RED}❌ Request gagal dengan status: $status_code${NC}"
    # log failure
    log_header "mencari" "$q"
    printf "HTTP_STATUS: %s\n" "$status_code" >> "$LOGFILE"
    printf "RAW_BODY:\n%s\n" "$body" >> "$LOGFILE"
    log_footer
    read -p "Enter untuk kembali..."
    return
  fi

  if echo "$body" | grep -q "<"; then
    echo -e "${RED}❌ Server mengembalikan HTML — kemungkinan endpoint salah atau token invalid.${NC}"
    log_header "mencari" "$q"
    printf "ERROR: server returned HTML\nRAW_BODY:\n%s\n" "$body" >> "$LOGFILE"
    log_footer
    read -p "Enter untuk kembali..."
    return
  fi

  if ! echo "$body" | jq empty >/dev/null 2>&1; then
    echo -e "${RED}❌ Gagal parsing JSON. Menyimpan raw response ke log.${NC}"
    log_header "mencari" "$q"
    printf "RAW_BODY:\n%s\n" "$body" >> "$LOGFILE"
    log_footer
    read -p "Enter untuk kembali..."
    return
  fi

  # no error: print and log
  echo -e "${GREEN}✅ Respons berhasil diterima:${NC}"
  echo "$body" | jq

  log_header "mencari" "$q"
  printf "RAW_BODY:\n" >> "$LOGFILE"
  printf "%s\n" "$body" >> "$LOGFILE"
  printf "\nSUMMARY:\n" >> "$LOGFILE"
  echo "$body" | jq -r '.' | sed 's/^/ - /' >> "$LOGFILE"
  log_footer

  read -p "Tekan Enter untuk kembali ke menu..."
}

# ===== [4] gemini_case (AI) =====
# ===== [4] gemini_case (AI Chat Persistent) =====
gemini_case() {
  clear; banner
  echo -e "${YELLOW}🤖 Mode Chat Gemini — ketik 'exit' untuk keluar.${NC}"
  echo -e "${MAGENTA}──────────────────────────────────────────────${NC}"

  # pastikan jq tersedia
  if ! command -v jq >/dev/null 2>&1; then
    echo -e "${YELLOW}📦 Menginstal jq...${NC}"
    pkg install jq -y >/dev/null 2>&1 || {
      echo -e "${RED}❌ Gagal menginstal jq.${NC}"
      read -p "Enter untuk kembali..."
      return
    }
  fi

  GEMINI_API_KEY="AIzaSyBWi8SB9xv5qk_KLARf6ZGi27pkkyNJIQ8"
  MODEL="gemini-2.5-flash"

  SESSION_FILE="/sdcard/script/projek/fa-mux/.object/tools/session_gemini.json"
  LOGFILE="/sdcard/script/projek/fa-mux/.object/tools/log.txt"

  mkdir -p "$(dirname "$SESSION_FILE")" 2>/dev/null || true
  mkdir -p "$(dirname "$LOGFILE")" 2>/dev/null || true

  # mulai dengan array kosong kalau belum ada
  if [[ ! -s "$SESSION_FILE" ]]; then
    echo '{"contents":[]}' > "$SESSION_FILE"
  fi

  while true; do
    echo
    read -p "💬 Kamu: " text
    [[ -z "$text" ]] && continue
    [[ "$text" == "exit" ]] && {
      echo -e "${RED}🚪 Keluar dari mode chat...${NC}"
      break
    }

    TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

    if [[ -f "$text" ]]; then
      FILE="$text"
      TYPE=$(file --mime-type -b "$FILE")
      SIZE=$(stat -c%s "$FILE" 2>/dev/null || stat -f%z "$FILE")
      BASENAME=$(basename "$FILE")

      echo -e "📂 Membaca file: $FILE"
      echo -e "📄 Tipe: ${TYPE}"
      echo -e "📦 Ukuran: ${SIZE} bytes"
      echo -e "🧩 Mengirim file inline (base64)..."

      BASE64_CONTENT=$(base64 -w 0 "$FILE")

      # simpan ke sesi JSON
      updated=$(jq --arg name "$BASENAME" \
                   --arg mime "$TYPE" \
                   --arg b64 "$BASE64_CONTENT" \
                   '.contents += [{"role":"user","parts":[{"inline_data":{"mime_type":$mime,"data":$b64}}]}]' "$SESSION_FILE")
      echo "$updated" > "$SESSION_FILE"

      # tulis ke log
      {
        echo "[$TIMESTAMP]"
        echo "USER: $FILE"
        echo "FILE: $TYPE ($SIZE bytes)"
      } >> "$LOGFILE"

    else
      # teks biasa
      updated=$(jq --arg txt "$text" '.contents += [{"role":"user","parts":[{"text":$txt}]}]' "$SESSION_FILE")
      echo "$updated" > "$SESSION_FILE"

      {
        echo "[$TIMESTAMP]"
        echo "USER: $text"
      } >> "$LOGFILE"
    fi

    echo -e "${YELLOW}⚙️  Mengirim ke Gemini...${NC}"

    RESPONSE=$(curl -s -X POST \
      "https://generativelanguage.googleapis.com/v1beta/models/${MODEL}:generateContent?key=${GEMINI_API_KEY}" \
      -H "Content-Type: application/json" \
      -d @"$SESSION_FILE")

    if ! echo "$RESPONSE" | jq -e '.candidates' >/dev/null 2>&1; then
      echo -e "${RED}❌ Gagal mendapatkan respons dari Gemini.${NC}"
      echo "$RESPONSE" | jq .
      {
        echo "BOT: [ERROR] Tidak ada respons valid"
        echo "────────────────────────────"
      } >> "$LOGFILE"
      continue
    fi

    RESULT=$(echo "$RESPONSE" | jq -r '.candidates[0].content.parts[0].text')

    echo -e "\n${GREEN}🪄 Gemini:${NC}\n${WHITE}$RESULT${NC}"

    # simpan respons ke sesi dan log
    updated=$(jq --arg txt "$RESULT" '.contents += [{"role":"model","parts":[{"text":$txt}]}]' "$SESSION_FILE")
    echo "$updated" > "$SESSION_FILE"

    {
      echo "BOT: $RESULT"
      echo "────────────────────────────"
    } >> "$LOGFILE"
  done

  read -p "Tekan Enter untuk kembali ke menu..."
}

# ====== FUNGSI DOMAIN ======
#!/bin/bash

# ===== WARNA =====
RED="\033[0;31m"
GREEN="\033[0;32m"
YELLOW="\033[1;33m"
WHITE="\033[1;37m"
MAGENTA="\033[0;35m"
NC="\033[0m"

# ====== LOKASI LOG ======
LOG_PATH="/sdcard/script/projek/fa-mux/.object/tools"
LOG_FILE="$LOG_PATH/log.txt"

mkdir -p "$LOG_PATH" 2>/dev/null
touch "$LOG_FILE"

# ====== FUNGSI DOMAIN ======
domain_case() {
  clear; banner
  echo -e "${MAGENTA}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo -e "${YELLOW}⚙️  Tambah Subdomain ke Cloudflare${NC}"
  echo -e "${MAGENTA}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo

  # === Konfigurasi Cloudflare ===
  ZONE_ID="f0daa6f9935296960df05e35f2c890a0"
  API_TOKEN="BYIp7Rs3_iXJFlQKxLtFmH5PpWLW86HzxkQn0ELq"
  TLD="ptero-panel.web.id"

  read -p "Masukkan Hostname (contoh: test) : " HOSTNAME
  read -p "Masukkan IP Address (contoh: 1.2.3.4) : " IP_ADDR

  # Validasi input
  HOSTNAME=$(echo "$HOSTNAME" | tr -cd 'a-zA-Z0-9.-')
  IP_ADDR=$(echo "$IP_ADDR" | tr -cd '0-9.')

  if [[ -z "$HOSTNAME" || -z "$IP_ADDR" ]]; then
    echo -e "${RED}❌ Hostname atau IP tidak boleh kosong${NC}"
    echo "$(date '+%Y-%m-%d %H:%M:%S') [ERROR] Hostname/IP kosong" >> "$LOG_FILE"
    read -n 1 -s -r -p "Tekan apapun untuk kembali ke menu..."
    return
  fi

  echo
  echo -e "${YELLOW}🔄 Menambahkan subdomain...${NC}"
  sleep 1

  RESPONSE=$(curl -s -X POST "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records" \
    -H "Authorization: Bearer $API_TOKEN" \
    -H "Content-Type: application/json" \
    --data "$(jq -n \
      --arg type "A" \
      --arg name "$HOSTNAME.$TLD" \
      --arg content "$IP_ADDR" \
      --argjson ttl 3600 \
      --argjson priority 10 \
      --argjson proxied false \
      '{type: $type, name: $name, content: $content, ttl: $ttl, priority: $priority, proxied: $proxied}')")

  SUCCESS=$(echo "$RESPONSE" | jq -r '.success')

  clear; banner
  if [[ "$SUCCESS" == "true" ]]; then
    NAME=$(echo "$RESPONSE" | jq -r '.result.name')
    IP=$(echo "$RESPONSE" | jq -r '.result.content')
    echo -e "${GREEN}✅ Berhasil Menambah Subdomain${NC}"
    echo -e "🌐 Hostname : ${YELLOW}$NAME${NC}"
    echo -e "💾 IP Address : ${YELLOW}$IP${NC}"
    echo -e "\n⚡ ${MAGENTA}Subdomain FannyFa berhasil ditambahkan!${NC}"

    # simpan ke log
    echo "$(date '+%Y-%m-%d %H:%M:%S') [SUCCESS] Hostname: $NAME | IP: $IP" >> "$LOG_FILE"
  else
    ERROR=$(echo "$RESPONSE" | jq -r '.errors[0].message // "Terjadi kesalahan"')
    echo -e "${RED}❌ Gagal membuat subdomain${NC}"
    echo -e "Pesan: ${YELLOW}$ERROR${NC}"

    # simpan ke log
    echo "$(date '+%Y-%m-%d %H:%M:%S') [FAILED] Host: $HOSTNAME.$TLD | IP: $IP_ADDR | Error: $ERROR" >> "$LOG_FILE"
  fi

  echo
  read -n 1 -s -r -p "Tekan apapun untuk kembali ke menu..."
}
#!/bin/bash

# =====================[ Warna Terminal ]=====================
RED="\e[31m"; GREEN="\e[32m"; YELLOW="\e[33m"
BLUE="\e[34m"; CYAN="\e[36m"; MAGENTA="\e[35m"; WHITE="\e[37m"
NC="\e[0m"

CONFIG_FILE="/sdcard/script/projek/fa-mux/.object/tools/.panel_config"

# =====================[ Logging Function ]=====================
log() {
  echo "$(date '+%Y-%m-%d %H:%M:%S') | $*" >> "$LOG_FILE"
}

# =====================[ Load Config Panel ]=====================
load_panel_config() {
  if [[ -f "$CONFIG_FILE" ]]; then
    source "$CONFIG_FILE"
  fi
}

# =====================[ Save Config Panel ]=====================
panel_config_interactive() {
  echo -e "${YELLOW}Masukkan konfigurasi API Pterodactyl:${NC}"
  read -p "Domain (contoh: https://panel.example.com/): " domain
  read -p "API Key (Application Key): " apikey
  read -p "Client API Key (jika ada, tekan enter jika tidak): " /
  read -p "Egg ID (default 15): " eggs
  read -p "Location ID (default 1): " locc

  [[ -z "$eggs" ]] && eggs="15"
  [[ -z "$locc" ]] && locc="1"

  cat > "$CONFIG_FILE" <<EOF
DOMAIN="$domain"
APIKEY="$apikey"
CAPIKEY="$capikey"
EGGS="$eggs"
LOCC="$locc"
EOF

  echo -e "${GREEN}✅ Konfigurasi berhasil disimpan ke $CONFIG_FILE${NC}"
  sleep 1
}

# =====================[ Tampilkan Config Summary ]=====================
show_panel_config_summary() {
  load_panel_config
  echo -e "${CYAN}=== CONFIG SUMMARY ===${NC}"
  echo "Domain : ${DOMAIN:-Belum diatur}"
  echo "APIKey : ${APIKEY:-Belum diatur}"
  echo "Egg ID : ${EGGS:-Belum diatur}"
  echo "Loc ID : ${LOCC:-Belum diatur}"
  echo -e "${CYAN}=======================${NC}"
}

# =====================[ Fungsi API Create User ]=====================
create_user() {
  curl -s -X POST "${DOMAIN}api/application/users" \
    -H "Authorization: Bearer $APIKEY" \
    -H "Content-Type: application/json" \
    -H "Accept: application/json" \
    -d "$(jq -n \
      --arg email "$1" \
      --arg username "$2" \
      --arg first_name "$2" \
      --arg last_name "$2" \
      --arg language "en" \
      --arg password "$3" \
      '{email:$email, username:$username, first_name:$first_name, last_name:$last_name, language:$language, password:$password}')"
}

# =====================[ Fungsi API Get Egg Info ]=====================
get_egg() {
  curl -s -X GET "${DOMAIN}api/application/nests/5/eggs/${EGGS}" \
    -H "Authorization: Bearer $APIKEY" \
    -H "Accept: application/json" \
    -H "Content-Type: application/json"
}

# =====================[ Fungsi API Create Server ]=====================
create_server() {
  local username="$1" user_id="$2" memo="$3" disk="$4" cpu="$5" startup="$6"
  curl -s -X POST "${DOMAIN}api/application/servers" \
    -H "Authorization: Bearer $APIKEY" \
    -H "Accept: application/json" \
    -H "Content-Type: application/json" \
    -d "$(jq -n \
      --arg name "$username" \
      --arg desc "Cpanel" \
      --arg user "$user_id" \
      --argjson egg "$EGGS" \
      --arg docker "ghcr.io/parkervcp/yolks:nodejs_20" \
      --arg startup "$startup" \
      --argjson memo "$memo" \
      --argjson disk "$disk" \
      --argjson cpu "$cpu" \
      --argjson loc "$LOCC" \
      '{name:$name, description:$desc, user:($user|tonumber), egg:$egg,
        docker_image:$docker, startup:$startup,
        environment:{INST:"npm", USER_UPLOAD:"0", AUTO_UPDATE:"0", CMD_RUN:"npm start"},
        limits:{memory:$memo, swap:0, disk:$disk, io:500, cpu:$cpu},
        feature_limits:{databases:0, backups:0, allocations:0},
        deploy:{locations:[$loc], dedicated_ip:false, port_range:[]}}')"
}

# =====================[ Fitur Buat Panel ]=====================
cpanel_create_runner() {
  load_panel_config
  if [[ -z "$DOMAIN" || -z "$APIKEY" ]]; then
    echo -e "${RED}Error: Config belum diatur. Jalankan Setup Config dulu.${NC}"
    sleep 1.3
    return 1
  fi

  local raw
  read -p "Masukkan input (contoh: 1gb-fannyfa-pw): " raw
  IFS='-' read -r ukuran username password <<< "$raw"

  [[ -z "$ukuran" || -z "$username" ]] && {
    echo -e "${RED}❌ Format salah. Gunakan contoh: 1gb-fannyfa-pw${NC}"
    return 1
  }

  ukuran="${ukuran,,}"
  case "$ukuran" in
    1gb) memo=1024; disk=1024; cpu=30 ;;
    2gb) memo=2048; disk=2048; cpu=50 ;;
    3gb) memo=3072; disk=3072; cpu=60 ;;
    4gb) memo=4096; disk=4096; cpu=80 ;;
    5gb) memo=5120; disk=5120; cpu=90 ;;
    6gb) memo=6144; disk=6144; cpu=100 ;;
    7gb) memo=7168; disk=7168; cpu=120 ;;
    8gb) memo=8192; disk=8192; cpu=140 ;;
    9gb) memo=9216; disk=9216; cpu=150 ;;
    10gb) memo=10240; disk=10240; cpu=190 ;;
    unli) memo=0; disk=0; cpu=0 ;;
    *) echo -e "${RED}Ukuran tidak valid!${NC}"; return 1 ;;
  esac

  if [[ -z "$password" ]]; then
    password=$(LC_ALL=C tr -dc 'A-Za-z0-9' </dev/urandom | head -c8)
  fi
  local email="${username}@gmail.com"

  echo -e "\n${YELLOW}Membuat user ${username}...${NC}"
  user_resp=$(create_user "$email" "$username" "$password")

  user_id=$(echo "$user_resp" | jq -r '.attributes.id // .id')
  [[ "$user_id" == "null" || -z "$user_id" ]] && {
    echo -e "${RED}Gagal membuat user!${NC}"
    echo "$user_resp" | jq
    log "Gagal membuat user: $username"
    return 1
  }

  egg_resp=$(get_egg)
  startup=$(echo "$egg_resp" | jq -r '.attributes.startup // "npm start"')

  echo -e "${YELLOW}Membuat server...${NC}"
  server_resp=$(create_server "$username" "$user_id" "$memo" "$disk" "$cpu" "$startup")

  server_id=$(echo "$server_resp" | jq -r '.attributes.id // .id')
  [[ "$server_id" == "null" || -z "$server_id" ]] && {
    echo -e "${RED}Gagal membuat server!${NC}"
    echo "$server_resp" | jq
    log "Gagal membuat server untuk user: $username"
    return 1
  }

  echo -e "\n${GREEN}✅ SUKSES MEMBUAT CPANEL${NC}"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "Username : $username"
  echo "Password : $password"
  echo "Email    : $email"
  echo "ServerID : $server_id"
  echo "RAM      : ${memo}MB"
  echo "Disk     : ${disk}MB"
  echo "CPU      : ${cpu}%"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━"
  log "Sukses: $username ($ukuran) ServerID: $server_id"
}

# =====================[ Clear Log Function ]=====================
clear_log() {
  echo -n > "$LOG_FILE"
  echo -e "${GREEN}✅ Log berhasil dikosongkan.${NC}"
}
# =====================[ Fitur: Suspend / Unsuspend / Reinstall / Power Control ]=====================
suspend_server() {
  load_panel_config
  read -p "Masukkan ID server yang ingin di-suspend: " srv
  [[ -z "$srv" ]] && { echo -e "${RED}❌ ID server wajib diisi${NC}"; return; }
  
  resp=$(curl -s -X POST "${DOMAIN}api/application/servers/${srv}/suspend" \
    -H "Accept: application/json" \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer ${APIKEY}")
    
  if echo "$resp" | grep -q "errors"; then
    echo -e "${RED}❌ Server tidak ditemukan${NC}"
    log "ERROR suspend_server ID:$srv resp:$(echo "$resp" | tr '\n' ' ')"
  else
    echo -e "${GREEN}✅ Sukses suspend server ID:${srv}${NC}"
    log "SUCCESS suspend server:$srv"
  fi
}

unsuspend_server() {
  load_panel_config
  read -p "Masukkan ID server yang ingin di-unsuspend: " srv
  [[ -z "$srv" ]] && { echo -e "${RED}❌ ID server wajib diisi${NC}"; return; }

  resp=$(curl -s -X POST "${DOMAIN}api/application/servers/${srv}/unsuspend" \
    -H "Accept: application/json" \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer ${APIKEY}")

  if echo "$resp" | grep -q "errors"; then
    echo -e "${RED}❌ Server tidak ditemukan${NC}"
    log "ERROR unsuspend_server ID:$srv resp:$(echo "$resp" | tr '\n' ' ')"
  else
    echo -e "${GREEN}✅ Sukses membuka suspend server ID:${srv}${NC}"
    log "SUCCESS unsuspend server:$srv"
  fi
}

reinstall_server() {
  load_panel_config
  read -p "Masukkan ID server yang ingin di-reinstall: " srv
  [[ -z "$srv" ]] && { echo -e "${RED}❌ ID server wajib diisi${NC}"; return; }

  resp=$(curl -s -X POST "${DOMAIN}api/application/servers/${srv}/reinstall" \
    -H "Accept: application/json" \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer ${APIKEY}")

  if echo "$resp" | grep -q "errors"; then
    echo -e "${RED}❌ Server tidak ditemukan${NC}"
    log "ERROR reinstall_server ID:$srv resp:$(echo "$resp" | tr '\n' ' ')"
  else
    echo -e "${GREEN}🔄 Server ID:${srv} sedang direinstall...${NC}"
    log "SUCCESS reinstall server:$srv"
  fi
}

power_control() {
  load_panel_config
  echo -e "${YELLOW}Pilih aksi power:${NC}"
  echo "1) Start"
  echo "2) Stop"
  echo "3) Restart"
  read -p "Pilih [1-3]: " actnum
  case "$actnum" in
    1) action="start" ;;
    2) action="stop" ;;
    3) action="restart" ;;
    *) echo -e "${RED}❌ Pilihan tidak valid${NC}"; return ;;
  esac

  read -p "Masukkan ID server: " srv
  [[ -z "$srv" ]] && { echo -e "${RED}❌ ID server wajib diisi${NC}"; return; }

  resp=$(curl -s -X POST "${DOMAIN}api/client/servers/${srv}/power" \
    -H "Accept: application/json" \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer ${APIKEY}" \
    -d "{\"signal\":\"${action}\"}")

  if echo "$resp" | grep -q "errors"; then
    echo -e "${RED}❌ Gagal melakukan aksi power${NC}"
    log "ERROR power_control $action ID:$srv resp:$(echo "$resp" | tr '\n' ' ')"
  else
    echo -e "${GREEN}⚙️  Sukses ${action^^} server ID:${srv}${NC}"
    log "SUCCESS power_control $action server:$srv"
  fi
}

# =====================[ Menu Utama ]=====================
cpanel_case() {
  while true; do
    clear; banner
    echo -e "${MAGENTA}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${WHITE}1.${YELLOW} Setup Config API${NC}"
    echo -e "${WHITE}2.${YELLOW} Buat CPanel Baru${NC}"
    echo -e "${WHITE}3.${YELLOW} Lihat Config${NC}"
    echo -e "${WHITE}4.${YELLOW} Clear Log${NC}"
    echo -e "${WHITE}5.${YELLOW} Suspend Server${NC}"
    echo -e "${WHITE}6.${YELLOW} Unsuspend Server${NC}"
    echo -e "${WHITE}7.${YELLOW} Reinstall Server${NC}"
    echo -e "${WHITE}8.${YELLOW} Power Control (Start/Stop/Restart)${NC}"
    echo -e "${WHITE}0.${RED} Keluar${NC}"
    echo -e "${MAGENTA}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${CYAN}Ketik 'log' untuk melihat log atau 'clear_log' untuk hapus log.${NC}"
    echo
    read -p "Pilih menu [0-4]: " pilih
    case "$pilih" in
      1) panel_config_interactive ;;
      2) cpanel_create_runner ;;
      3) show_panel_config_summary; read -n1 -s -r -p "Tekan apapun untuk kembali..." ;;
      4|clear_log) clear_log; sleep 1 ;;
      5) suspend_server ;;
      6) unsuspend_server ;;
      7) reinstall_server ;;
      8) power_control ;;

      log) echo -e "${CYAN}=== LOG FILE ===${NC}"; cat "$LOG_FILE" 2>/dev/null || echo "Belum ada log."; read -n1 -s -r -p "Tekan apapun untuk kembali..." ;;
      0) break ;;
      *) echo -e "${RED}Pilihan tidak valid${NC}"; sleep 1 ;;
    esac
  done
}

# ===== MENU UTAMA =====
while true; do
  clear; banner
  echo -e "${CYAN} 1${WHITE}. Lacak IP"
  echo -e "${CYAN} 2${WHITE}. Cek Provider Nomor"
  echo -e "${CYAN} 3${WHITE}. Mencari (Premium)"
  echo -e "${CYAN} 4${WHITE}. Gemini AI Chat"
  echo -e "${CYAN} 5${WHITE}. Buat Cpanel"
  echo -e "${CYAN} 6${WHITE}. Tambah Subdomain (Cloudflare)"
  echo -e "${CYAN} 0${WHITE}. Keluar"
  echo -e "${MAGENTA}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo -e "💡 ${GRAY}Ketik '${YELLOW}log${GRAY}' untuk melihat log,
         '${RED}clear${GRAY}' untuk hapus log.${NC}"
  echo -e "${MAGENTA}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"
  read -p "❯ Pilih menu [0-5]: " pilih
  case $pilih in
    1) cekip_case ;;
    2) cekprovider_case ;;
    3) mencari_case ;;
    4) gemini_case ;;
    5) cpanel_case;;
    6) domain_case ;;
    0) clear; script 0 ;;
# ===== MENU TAMBAHAN =====
    clear) clear_log;;
    log) lihat_log;;
    *) echo -e "${RED}❌ Pilihan tidak valid${NC}"; sleep 1 ;;
  esac
done
