#!/bin/bash

# RobotTaxi Navigation Manager
# Comprehensive script to launch, log, and monitor navigation nodes
# Author: GitHub Copilot
# Date: 2025-06-25

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Global variables
WORKSPACE_DIR="/home/aaron/robotaxi_ws"
LOGS_DIR="$WORKSPACE_DIR/logs"
DIAGNOSTIC_LOG_PREFIX="diagnostic_plannerloglari"
LOCALPLANNER_LOG_PREFIX="localplannerloglari"

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_header() {
    echo -e "${CYAN}$1${NC}"
}

print_menu_item() {
    echo -e "${BLUE}$1${NC} $2"
}

# Function to show help
show_help() {
    print_header "🚗 RobotTaxi Navigation Manager"
    print_header "==============================="
    echo ""
    echo "Bu script, robotaxi navigation sisteminin tüm bileşenlerini yönetir:"
    echo ""
    print_menu_item "📋 KULLANIM:"
    echo "  $0 [OPTION]"
    echo ""
    print_menu_item "📋 SEÇENEKLER:"
    echo "  -h, --help              Bu yardım mesajını göster"
    echo "  -d, --diagnostic        Sadece diagnostic planner'ı çalıştır"
    echo "  -l, --localplanner      Sadece local planner'ı çalıştır"
    echo "  -n, --navigation        Her iki planner'ı birlikte çalıştır"
    echo "  -nm, --nav-monitor      Navigation başlat ve logları izle"
    echo "  -na, --nav-analyze      Navigation başlat ve analiz et"
    echo "  -m, --monitor           Mevcut log dosyalarını izle"
    echo "  -a, --analyze           Log dosyalarını analiz et"
    echo "  -c, --clean             Log dosyalarını temizle"
    echo "  -s, --status            Çalışan node'ları ve topic'leri kontrol et"
    echo "  -k, --kill              Tüm navigation node'larını durdur"
    echo "  -i, --interactive       Interaktif menü modunu başlat"
    echo ""
    print_menu_item "📋 ÖRNEKLER:"
    echo "  $0 -n                   # Her iki planner'ı çalıştır"
    echo "  $0 -nm                  # Navigation + monitoring"
    echo "  $0 -na                  # Navigation + analiz"
    echo "  $0 -m                   # Log'ları izle"
    echo "  $0 -a                   # Log'ları analiz et"
    echo "  $0 -i                   # Interaktif menü"
    echo ""
}

# Function to check ROS2 environment
check_ros_environment() {
    if [ -z "$ROS_DISTRO" ]; then
        print_error "ROS2 environment bulunamadı. Lütfen ROS2'yi source edin:"
        echo "  source /opt/ros/humble/setup.bash"
        echo "  source install/setup.bash"
        return 1
    fi
    
    if [ ! -f "$WORKSPACE_DIR/install/setup.bash" ]; then
        print_error "Workspace build edilmemiş. Lütfen önce build edin:"
        echo "  cd $WORKSPACE_DIR"
        echo "  colcon build"
        return 1
    fi
    
    print_status "ROS2 environment: $ROS_DISTRO ✓"
    return 0
}

# Function to setup logs directory
setup_logs_directory() {
    if [ ! -d "$LOGS_DIR" ]; then
        mkdir -p "$LOGS_DIR"
        print_status "Log dizini oluşturuldu: $LOGS_DIR"
    fi
}

# Function to generate timestamp
get_timestamp() {
    date +"%Y%m%d_%H%M%S"
}

# Function to launch diagnostic planner with logging
launch_diagnostic_planner() {
    print_header "🔧 Diagnostic Planner Başlatılıyor..."
    
    setup_logs_directory
    
    local timestamp=$(get_timestamp)
    local log_file="$LOGS_DIR/${DIAGNOSTIC_LOG_PREFIX}_${timestamp}.log"
    local latest_link="$LOGS_DIR/${DIAGNOSTIC_LOG_PREFIX}_latest.log"
    
    print_status "Log dosyası: $log_file"
    
    # Remove old symlink and create new one
    rm -f "$latest_link"
    ln -s "${DIAGNOSTIC_LOG_PREFIX}_${timestamp}.log" "$latest_link"
    
    print_status "Diagnostic planner başlatılıyor..."
    echo "=== Diagnostic Planner Log - $(date) ===" > "$log_file"
    
    # Launch with proper environment sourcing in a subshell
    (
        cd "$WORKSPACE_DIR"
        source /opt/ros/humble/setup.bash
        source install/setup.bash
        export PYTHONUNBUFFERED=1
        python3 src/robotaxi_nav/nodes/diagnostic_planner.py
    ) >> "$log_file" 2>&1 &
    
    local pid=$!
    
    print_status "Diagnostic planner başlatıldı (PID: $pid)"
    echo "$pid" > "$LOGS_DIR/diagnostic_planner.pid"
    
    return 0
}

# Function to launch local planner with logging
launch_local_planner() {
    print_header "🎯 Local Planner Başlatılıyor..."
    
    setup_logs_directory
    
    local timestamp=$(get_timestamp)
    local log_file="$LOGS_DIR/${LOCALPLANNER_LOG_PREFIX}_${timestamp}.log"
    local latest_link="$LOGS_DIR/${LOCALPLANNER_LOG_PREFIX}_latest.log"
    
    print_status "Log dosyası: $log_file"
    
    # Remove old symlink and create new one
    rm -f "$latest_link"
    ln -s "${LOCALPLANNER_LOG_PREFIX}_${timestamp}.log" "$latest_link"
    
    print_status "Local planner başlatılıyor..."
    echo "=== Local Planner Log - $(date) ===" > "$log_file"
    
    # Launch with proper environment sourcing in a subshell
    (
        cd "$WORKSPACE_DIR"
        source /opt/ros/humble/setup.bash
        source install/setup.bash
        export PYTHONUNBUFFERED=1
        python3 src/robotaxi_nav/nodes/localplanner.py
    ) >> "$log_file" 2>&1 &
    
    local pid=$!
    
    print_status "Local planner başlatıldı (PID: $pid)"
    echo "$pid" > "$LOGS_DIR/localplanner.pid"
    
    return 0
}

# Function to launch both planners
launch_navigation() {
    print_header "🚗 Navigation Sistemi Başlatılıyor..."
    
    if ! check_ros_environment; then
        return 1
    fi
    
    print_status "Her iki planner da başlatılıyor..."
    
    launch_diagnostic_planner
    sleep 2
    launch_local_planner
    
    print_status "Navigation sistemi başarıyla başlatıldı!"
    print_status "Log dosyalarını izlemek için: $0 -m"
    
    return 0
}

# Function to analyze logs using Python script
analyze_logs() {
    print_header "📊 Log Dosyaları Analiz Ediliyor..."
    
    if [ ! -d "$LOGS_DIR" ]; then
        print_error "Log dizini bulunamadı."
        return 1
    fi
    
    # Check if Python analyzer exists
    if [ ! -f "$WORKSPACE_DIR/analyze_logs.py" ]; then
        print_error "analyze_logs.py dosyası bulunamadı."
        return 1
    fi
    
    cd "$WORKSPACE_DIR"
    python3 analyze_logs.py --latest
}

# Function to launch navigation with integrated monitoring
launch_navigation_with_monitoring() {
    print_header "🚗 Navigation Sistemi + Monitor Başlatılıyor..."
    
    if ! check_ros_environment; then
        return 1
    fi
    
    print_status "Her iki planner başlatılıyor ve loglanıyor..."
    
    # Launch both planners
    launch_diagnostic_planner
    sleep 3
    launch_local_planner
    sleep 2
    
    print_status "Navigation sistemi başarıyla başlatıldı!"
    print_status "5 saniye sonra log monitoring başlayacak..."
    sleep 5
    
    # Start monitoring
    monitor_logs
}

# Function to launch navigation and show analysis
launch_navigation_with_analysis() {
    print_header "🚗 Navigation Sistemi + Analiz Başlatılıyor..."
    
    if ! check_ros_environment; then
        return 1
    fi
    
    print_status "Her iki planner başlatılıyor..."
    
    # Launch both planners
    launch_diagnostic_planner
    sleep 3
    launch_local_planner
    sleep 2
    
    print_status "Navigation sistemi başlatıldı!"
    print_status "10 saniye log biriktiriliyor..."
    sleep 10
    
    # Analyze logs
    analyze_logs
    
    print_status "Log analizi tamamlandı. Monitor için: $0 -m"
}

# Function to monitor logs
monitor_logs() {
    print_header "📊 Log Dosyaları İzleniyor..."
    
    # Check if logs directory exists
    if [ ! -d "$LOGS_DIR" ]; then
        print_error "Log dizini bulunamadı. Önce navigation scriptlerini çalıştırın."
        return 1
    fi
    
    # Check if latest log symlinks exist
    local diagnostic_log="$LOGS_DIR/${DIAGNOSTIC_LOG_PREFIX}_latest.log"
    local localplanner_log="$LOGS_DIR/${LOCALPLANNER_LOG_PREFIX}_latest.log"
    
    if [ ! -f "$diagnostic_log" ] || [ ! -f "$localplanner_log" ]; then
        print_error "Latest log dosyaları bulunamadı. Mevcut loglar:"
        ls -la "$LOGS_DIR/"
        echo ""
        print_warning "Önce navigation scriptlerini çalıştırın:"
        echo "  $0 -n     (her iki node)"
        echo "  $0 -d     (diagnostic planner)"
        echo "  $0 -l     (local planner)"
        return 1
    fi
    
    print_status "Log dosyaları:"
    echo "   Diagnostic: $diagnostic_log"
    echo "   Local:      $localplanner_log"
    echo ""
    
    # Check if multitail is available
    if command -v multitail &> /dev/null; then
        print_status "Multitail ile split view kullanılıyor (çıkmak için 'q')"
        echo "==================================="
        multitail -s 2 \
            -t "Diagnostic Planner" "$diagnostic_log" \
            -t "Local Planner" "$localplanner_log"
    else
        print_warning "Multitail mevcut değil, alternatif yöntem kullanılıyor"
        print_status "Daha iyi görüntüleme için multitail kurun: sudo apt install multitail"
        echo "==================================="
        echo ""
        print_header "📊 DIAGNOSTIC PLANNER LOG:"
        echo "-------------------"
        tail -f "$diagnostic_log" &
        local tail1_pid=$!
        
        echo ""
        print_header "📊 LOCAL PLANNER LOG:"
        echo "------------------"
        tail -f "$localplanner_log" &
        local tail2_pid=$!
        
        # Function to handle cleanup
        cleanup() {
            echo ""
            print_status "Log izleme durduruluyor..."
            kill $tail1_pid $tail2_pid 2>/dev/null
            exit 0
        }
        
        # Set trap to handle Ctrl+C
        trap cleanup SIGINT SIGTERM
        
        echo ""
        print_warning "Durdurmak için Ctrl+C'ye basın"
        wait
    fi
}

# Function to clean logs
clean_logs() {
    print_header "🧹 Log Dosyaları Temizleniyor..."
    
    if [ ! -d "$LOGS_DIR" ]; then
        print_warning "Log dizini bulunamadı."
        return 0
    fi
    
    local log_count=$(find "$LOGS_DIR" -name "*.log" | wc -l)
    
    if [ $log_count -eq 0 ]; then
        print_warning "Temizlenecek log dosyası bulunamadı."
        return 0
    fi
    
    print_status "$log_count log dosyası bulundu."
    read -p "Tüm log dosyalarını silmek istediğinizden emin misiniz? (y/N): " -n 1 -r
    echo
    
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        rm -f "$LOGS_DIR"/*.log
        rm -f "$LOGS_DIR"/*.pid
        print_status "Log dosyaları temizlendi."
    else
        print_status "İşlem iptal edildi."
    fi
}

# Function to check status
check_status() {
    print_header "📊 Navigation Sistemi Durumu"
    print_header "============================"
    
    cd "$WORKSPACE_DIR"
    source install/setup.bash 2>/dev/null
    
    print_status "Çalışan ROS2 node'ları:"
    ros2 node list 2>/dev/null | grep -E "(diagnostic|local)" || print_warning "Navigation node'ları bulunamadı"
    
    echo ""
    print_status "Aktif topic'ler:"
    ros2 topic list 2>/dev/null | grep -E "(scan|map|goal|state|path|cmd_vel)" || print_warning "Navigation topic'leri bulunamadı"
    
    echo ""
    print_status "PID dosyaları:"
    if [ -f "$LOGS_DIR/diagnostic_planner.pid" ]; then
        local dpid=$(cat "$LOGS_DIR/diagnostic_planner.pid")
        if ps -p $dpid > /dev/null; then
            echo "  Diagnostic planner: PID $dpid (çalışıyor)"
        else
            echo "  Diagnostic planner: PID $dpid (durmuş)"
        fi
    else
        echo "  Diagnostic planner: PID dosyası yok"
    fi
    
    if [ -f "$LOGS_DIR/localplanner.pid" ]; then
        local lpid=$(cat "$LOGS_DIR/localplanner.pid")
        if ps -p $lpid > /dev/null; then
            echo "  Local planner: PID $lpid (çalışıyor)"
        else
            echo "  Local planner: PID $lpid (durmuş)"
        fi
    else
        echo "  Local planner: PID dosyası yok"
    fi
}

# Function to kill all navigation nodes
kill_navigation() {
    print_header "🛑 Navigation Node'ları Durduruluyor..."
    
    # Kill by PID files
    if [ -f "$LOGS_DIR/diagnostic_planner.pid" ]; then
        local dpid=$(cat "$LOGS_DIR/diagnostic_planner.pid")
        if ps -p $dpid > /dev/null; then
            kill $dpid
            print_status "Diagnostic planner durduruldu (PID: $dpid)"
        fi
        rm -f "$LOGS_DIR/diagnostic_planner.pid"
    fi
    
    if [ -f "$LOGS_DIR/localplanner.pid" ]; then
        local lpid=$(cat "$LOGS_DIR/localplanner.pid")
        if ps -p $lpid > /dev/null; then
            kill $lpid
            print_status "Local planner durduruldu (PID: $lpid)"
        fi
        rm -f "$LOGS_DIR/localplanner.pid"
    fi
    
    # Also try to kill by process name
    pkill -f "diagnostic_planner" 2>/dev/null && print_status "Diagnostic planner process'leri durduruldu"
    pkill -f "localplanner" 2>/dev/null && print_status "Local planner process'leri durduruldu"
    
    print_status "Tüm navigation node'ları durduruldu."
}

# Interactive menu
interactive_menu() {
    while true; do
        clear
        print_header "🚗 RobotTaxi Navigation Manager - İnteraktif Menü"
        print_header "================================================"
        echo ""
        print_menu_item "1)" "Navigation sistemi başlat (her iki planner)"
        print_menu_item "2)" "Navigation + Monitoring (başlat ve logları izle)"
        print_menu_item "3)" "Navigation + Analiz (başlat ve analiz et)"
        print_menu_item "4)" "Sadece diagnostic planner başlat"
        print_menu_item "5)" "Sadece local planner başlat"
        print_menu_item "6)" "Log dosyalarını izle"
        print_menu_item "7)" "Log dosyalarını analiz et"
        print_menu_item "8)" "Sistem durumunu kontrol et"
        print_menu_item "9)" "Navigation node'larını durdur"
        print_menu_item "10)" "Log dosyalarını temizle"
        print_menu_item "11)" "Yardım göster"
        print_menu_item "12)" "Çıkış"
        echo ""
        
        read -p "Seçiminizi yapın (1-12): " choice
        
        case $choice in
            1)
                launch_navigation
                read -p "Devam etmek için Enter'a basın..."
                ;;
            2)
                launch_navigation_with_monitoring
                ;;
            3)
                launch_navigation_with_analysis
                read -p "Devam etmek için Enter'a basın..."
                ;;
            4)
                if check_ros_environment; then
                    launch_diagnostic_planner
                fi
                read -p "Devam etmek için Enter'a basın..."
                ;;
            5)
                if check_ros_environment; then
                    launch_local_planner
                fi
                read -p "Devam etmek için Enter'a basın..."
                ;;
            6)
                monitor_logs
                ;;
            7)
                analyze_logs
                read -p "Devam etmek için Enter'a basın..."
                ;;
            8)
                check_status
                read -p "Devam etmek için Enter'a basın..."
                ;;
            9)
                kill_navigation
                read -p "Devam etmek için Enter'a basın..."
                ;;
            10)
                clean_logs
                read -p "Devam etmek için Enter'a basın..."
                ;;
            11)
                show_help
                read -p "Devam etmek için Enter'a basın..."
                ;;
            12)
                print_status "Çıkılıyor..."
                exit 0
                ;;
            *)
                print_error "Geçersiz seçim. Lütfen 1-12 arası bir sayı girin."
                read -p "Devam etmek için Enter'a basın..."
                ;;
        esac
    done
}

# Main script logic
main() {
    # Change to workspace directory
    cd "$WORKSPACE_DIR" || {
        print_error "Workspace dizinine geçilemedi: $WORKSPACE_DIR"
        exit 1
    }
    
    # Parse command line arguments
    case "$1" in
        -h|--help)
            show_help
            exit 0
            ;;
        -d|--diagnostic)
            if check_ros_environment; then
                launch_diagnostic_planner
            else
                exit 1
            fi
            ;;
        -l|--localplanner)
            if check_ros_environment; then
                launch_local_planner
            else
                exit 1
            fi
            ;;
        -n|--navigation)
            launch_navigation
            ;;
        -nm|--nav-monitor)
            launch_navigation_with_monitoring
            ;;
        -na|--nav-analyze)
            launch_navigation_with_analysis
            ;;
        -m|--monitor)
            monitor_logs
            ;;
        -a|--analyze)
            analyze_logs
            ;;
        -c|--clean)
            clean_logs
            ;;
        -s|--status)
            check_status
            ;;
        -k|--kill)
            kill_navigation
            ;;
        -i|--interactive|"")
            interactive_menu
            ;;
        *)
            print_error "Bilinmeyen seçenek: $1"
            echo ""
            show_help
            exit 1
            ;;
    esac
}

# Run main function with all arguments
main "$@"
