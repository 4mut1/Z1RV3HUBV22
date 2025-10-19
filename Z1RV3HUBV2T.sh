#!/bin/bash

# Z1RV3 COMMİNUTY TOOL HUB (Ana Yönetim Betiği)
# GÜNCELLEME: The Harvester ve Masscan'in calistirma/kurulum hatalari giderildi.

# --- Yapılandırma ---
TOOLS_DIR="$HOME/Z1RV3COMMİNTYHUB" 

TOOL_URLS=(
    "https://github.com/4lbH4cker/ALHacking.git"           # 1. ALHacking
    "https://github.com/4mut1/4mutddoshackv1.git"          # 2. Kendi DDOS Tool'unuz
    "https://github.com/zeus289x/smsbomber.git"            # 3. SMS Bomber Toolu
    "https://github.com/laramies/theHarvester.git"         # 4. The Harvester (OSINT)
    "https://github.com/robertdavidgraham/masscan.git"     # 5. Masscan (Port Tarama)
    "https://github.com/lanmaster53/recon-ng.git"          # 6. Recon-ng (OSINT)
)
TOOL_NAMES=(
    "ALHacking (Al Hack Toolu)"
    "4muthackddosv1 (Kendi Toolunuz)"
    "SMS Bomber Toolu"
    "The Harvester (OSINT)"
    "Masscan (Hizli Port Tarama)"
    "Recon-ng (Gelistirilmis OSINT)"
)
TOOL_FOLDERS=(
    "ALHacking"
    "Z1RV3HACKDDOSV1"
    "smsbomber"
    "theHarvester"      # Klasör adını doğru repo adıyla eşleştirdim
    "masscan"           
    "recon-ng"          
)

# (Renkler ve header fonksiyonları aynı kaldı)
# ...

setup_tools() {
    header
    echo -e "${YELLOW}[I] Araclar Kuruluyor/Guncelleniyor...${NC}"
    mkdir -p "$TOOLS_DIR"
    cd "$TOOLS_DIR" || { echo -e "${RED}[HATA] Klasore gidilemedi!${NC}"; exit 1; }

    for i in "${!TOOL_URLS[@]}"; do
        NAME="${TOOL_NAMES[i]}"
        URL="${TOOL_URLS[i]}"
        FOLDER="${TOOL_FOLDERS[i]}"
        echo ""
        echo -e "${CYAN}--- $NAME ($FOLDER) Kontrol Ediliyor...${NC}"

        if [ -d "$FOLDER" ]; then
            echo -e "${YELLOW}[~] $NAME zaten kurulu. Guncelleniyor...${NC}"
            cd "$FOLDER" || { echo -e "${RED}[HATA] $FOLDER klasorune gidilemedi!${NC}"; exit 1; }
            git pull
            cd ..
        else
            echo -e "${GREEN}[+] $NAME klonlaniyor...${NC}"
            # Özel klasör adını ayarla veya varsayilan olarak klonla
            git clone "$URL" "$FOLDER"
        fi
    done
    
    # Masscan ve theHarvester icin ÖZEL KURULUM ADIMLARI
    
    # 1. Masscan Derlemesi
    if [ -d "$TOOLS_DIR/masscan" ]; then
        echo -e "${YELLOW}[~] Masscan derleme islemi deneniyor...${NC}"
        cd "$TOOLS_DIR/masscan" || exit 1
        
        echo -e "${YELLOW} Masscan bagimliliklari (gcc, make, libpcap-dev) kuruluyor...${NC}"
        sudo apt update > /dev/null 2>&1
        sudo apt install -y git gcc make libpcap-dev > /dev/null 2>&1
        
        echo -e "${YELLOW} Masscan derleniyor...${NC}"
        make > /dev/null 2>&1
        
        if [ -f "$TOOLS_DIR/masscan/bin/masscan" ]; then
            echo -e "${GREEN}[OK] Masscan basariyla derlendi!${NC}"
            chmod +x bin/masscan
        else
            echo -e "${RED}[HATA] Masscan derlenemedi. Lutfen elle kontrol edin (cd masscan; make).${NC}"
        fi
        cd ..
    fi
    
    # 2. The Harvester Bağımlılıkları
    if [ -d "$TOOLS_DIR/theHarvester" ]; then
        echo -e "${YELLOW}[~] The Harvester Python gereksinimleri kuruluyor...${NC}"
        cd "$TOOLS_DIR/theHarvester" || exit 1
        if [ -f "requirements.txt" ]; then
            pip3 install -r requirements.txt 2>/dev/null || echo -e "${RED}[HATA] theHarvester pip bagimliliklari kurulurken sorun olustu.${NC}"
        fi
        cd ..
    fi

    echo -e "${GREEN}[OK] Tum araclar kuruldu/guncellendi!${NC}"
    echo ""
    read -p "Devam etmek icin Enter tusuna basin..."
}

run_tool() {
    header
    echo -e "${YELLOW}[?] Lutfen calistirmak istediginiz araci secin:${NC}"
    
    # Menüyü dinamik olarak olustur
    for i in "${!TOOL_NAMES[@]}"; do
        echo -e "  ${GREEN}$((i+1)). ${TOOL_NAMES[i]}${NC}"
    done
    echo -e "  ${RED}0. Cikis${NC}"
    echo ""
    read -p "Seciminiz: " CHOICE
    
    # KESİN CALISTIRMA KOMUTLARI BURADA!
    case $CHOICE in
        1) TOOL_TO_RUN="ALHacking"; ENTRY_POINT="alhack.sh"; RUN_COMMAND="bash";;
        2) TOOL_TO_RUN="Z1RV3HACKDDOSV1"; ENTRY_POINT="1RV3HACKDDOSV1"; RUN_COMMAND="python3";;
        3) TOOL_TO_RUN="smsbomber"; ENTRY_POINT="smsbomber.py"; RUN_COMMAND="python";;
        
        # GÜNCELLENDİ
        4) TOOL_TO_RUN="theHarvester"; ENTRY_POINT="theHarvester.py"; RUN_COMMAND="python3";; # En yaygin dosya adi
        5) TOOL_TO_RUN="masscan"; ENTRY_POINT="bin/masscan"; RUN_COMMAND="sudo";; # Masscan derlendikten sonra 'bin' klasöründe olur
        
        6) TOOL_TO_RUN="recon-ng"; ENTRY_POINT="recon-ng"; RUN_COMMAND="./";; 
        
        0) echo -e "${CYAN}[X] Z1RV3 COMMINUTY TOOL HUB'dan cikiliyor. Gule gule!${NC}"; exit 0;;
        *) echo -e "${RED}[HATA] Gecersiz secim. Lutfen tekrar deneyin.${NC}"; sleep 2; return;;
    esac
    
    # Arac calistirma mantigi
    if [ -f "$TOOLS_DIR/$TOOL_TO_RUN/$ENTRY_POINT" ]; then
        header
        echo -e "${CYAN}--- ${TOOL_NAMES[CHOICE-1]} Araci Baslatiliyor (${RUN_COMMAND} ${ENTRY_POINT})...${NC}"
        cd "$TOOLS_DIR/$TOOL_TO_RUN" || { echo -e "${RED}[HATA] Klasore gidilemedi!${NC}"; sleep 3; return; }
        
        chmod +x "$ENTRY_POINT" 2>/dev/null || true
        
        if [ "$RUN_COMMAND" == "python3" ] || [ "$RUN_COMMAND" == "python" ]; then
            # The Harvester gibi Python script'lerini calistir
            $RUN_COMMAND "$ENTRY_POINT"
        elif [ "$RUN_COMMAND" == "bash" ]; then
            bash "$ENTRY_POINT"
        elif [ "$RUN_COMMAND" == "sudo" ]; then
            # Masscan calistirma: Tam yolu kullan (masscan'in bin/ klasorunde oldugunu varsayarak)
            sudo "$TOOLS_DIR/$TOOL_TO_RUN/$ENTRY_POINT" 
        elif [ "$RUN_COMMAND" == "./" ]; then
            # Recon-ng gibi dizin icindeki calistirılabilir dosyalari calistir
            ./"$ENTRY_POINT"
        fi

        echo ""
        read -p "Aracin calismasi bitti. Menuye donmek icin Enter tusuna basin..."
    else
        echo -e "${RED}[HATA] Calistirilabilir dosya bulunamadi: $ENTRY_POINT${NC}"
        echo -e "${YELLOW}[~] Lutfen $TOOLS_DIR/$TOOL_TO_RUN klasorunu kontrol edin ve betigi dogru dosya adiyla guncelleyin.${NC}"
        sleep 3
    fi
}
# (main_menu ve Baslangic kisimlari ayni kaldi)
# ...