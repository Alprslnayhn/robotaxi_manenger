# RobotTaxi Navigation Manager

Bu script, RobotTaxi navigation sisteminin tüm bileşenlerini tek bir yerden yönetmenizi sağlar. Diagnostic planner ve local planner'ı başlatma, log'lama, izleme ve durdurma işlemlerini kolaylaştırır.

## 🚀 Hızlı Başlangıç

```bash
# Script'i çalıştırılabilir yapın (sadece ilk kez)
chmod +x robotaxi_navigation_manager.sh

# İnteraktif menüyü başlatın
./robotaxi_navigation_manager.sh

# Veya doğrudan komut kullanın
./robotaxi_navigation_manager.sh -n  # Navigation sistemi başlat
```

## 📋 Kullanım Seçenekleri

| Komut | Açıklama |
|-------|----------|
| `-h, --help` | Yardım mesajını göster |
| `-d, --diagnostic` | Sadece diagnostic planner'ı çalıştır |
| `-l, --localplanner` | Sadece local planner'ı çalıştır |
| `-n, --navigation` | Her iki planner'ı birlikte çalıştır |
| `-nm, --nav-monitor` | Navigation başlat ve logları izle |
| `-na, --nav-analyze` | Navigation başlat ve analiz et |
| `-m, --monitor` | Mevcut log dosyalarını izle |
| `-a, --analyze` | Log dosyalarını analiz et |
| `-c, --clean` | Log dosyalarını temizle |
| `-s, --status` | Çalışan node'ları ve topic'leri kontrol et |
| `-k, --kill` | Tüm navigation node'larını durdur |
| `-i, --interactive` | İnteraktif menü modunu başlat |

## 🖥️ İnteraktif Menü

Parametre vermeden çalıştırdığınızda, kullanıcı dostu bir menü açılır:

```bash
./robotaxi_navigation_manager.sh
```

Menü seçenekleri:
1. **Navigation sistemi başlat** - Her iki planner'ı birlikte çalıştırır
2. **Navigation + Monitoring** - Başlatır ve otomatik log izleme
3. **Navigation + Analiz** - Başlatır ve log analizi yapar
4. **Sadece diagnostic planner başlat** - Yalnızca diagnostic planner
5. **Sadece local planner başlat** - Yalnızca local planner
6. **Log dosyalarını izle** - Real-time log monitoring
7. **Log dosyalarını analiz et** - Mevcut log'ları analiz et
8. **Sistem durumunu kontrol et** - Node ve topic durumları
9. **Navigation node'larını durdur** - Tüm planner'ları durdur
10. **Log dosyalarını temizle** - Eski log'ları sil
11. **Yardım göster** - Detaylı kullanım bilgisi
12. **Çıkış** - Script'ten çık

## 📊 Log Yönetimi

### Otomatik Log Oluşturma
Script çalıştırıldığında otomatik olarak log dosyaları oluşturur:

```
logs/
├── diagnostic_plannerloglari_20250625_160530.log
├── diagnostic_plannerloglari_latest.log -> diagnostic_plannerloglari_20250625_160530.log
├── localplannerloglari_20250625_160532.log
├── localplannerloglari_latest.log -> localplannerloglari_20250625_160532.log
├── diagnostic_planner.pid
└── localplanner.pid
```

### Log İzleme
```bash
# Multitail ile split view (önerilen)
sudo apt install multitail
./robotaxi_navigation_manager.sh -m

# Multitail yoksa otomatik olarak tail kullanır
./robotaxi_navigation_manager.sh -m
```

## 🔧 Komut Örnekleri

```bash
# Navigation sistemini başlat
./robotaxi_navigation_manager.sh -n

# Navigation + otomatik monitoring (önerilen!)
./robotaxi_navigation_manager.sh -nm

# Navigation + analiz
./robotaxi_navigation_manager.sh -na

# Log'ları izle
./robotaxi_navigation_manager.sh -m

# Log'ları analiz et
./robotaxi_navigation_manager.sh -a

# Durum kontrol et
./robotaxi_navigation_manager.sh -s

# Sistemi durdur
./robotaxi_navigation_manager.sh -k

# Log'ları temizle
./robotaxi_navigation_manager.sh -c
```

## 🛠️ Sistem Gereksinimleri

### ROS2 Environment
Script çalışmadan önce ROS2 environment'ın doğru şekilde source edilmiş olması gerekir:

```bash
source /opt/ros/humble/setup.bash
source install/setup.bash
```

### Workspace Build
Workspace'in build edilmiş olması gerekir:

```bash
colcon build
```

### İsteğe Bağlı: Multitail
Daha iyi log görüntüleme için:

```bash
sudo apt install multitail
```

## 📁 Dosya Yapısı

Script aşağıdaki dosyaları kullanır ve oluşturur:

```
robotaxi_ws/
├── robotaxi_navigation_manager.sh    # Ana script
├── logs/                            # Log dizini (otomatik oluşur)
│   ├── diagnostic_plannerloglari_*.log
│   ├── localplannerloglari_*.log
│   ├── *_latest.log                 # Son log'lara symlink
│   └── *.pid                        # Process ID dosyaları
├── src/robotaxi_nav/
│   ├── nodes/localplanner.py
│   ├── nodes/diagnostic_planner.py
│   └── config/navigation_params.yaml
└── install/                         # Build output
```

## 🚨 Sorun Giderme

### "ROS2 environment bulunamadı"
```bash
source /opt/ros/humble/setup.bash
source install/setup.bash
```

### "Workspace build edilmemiş"
```bash
cd /home/aaron/robotaxi_ws
colcon build
```

### "Latest log dosyaları bulunamadı"
```bash
# Önce navigation'ı başlatın
./robotaxi_navigation_manager.sh -n
# Sonra log'ları izleyin
./robotaxi_navigation_manager.sh -m
```

### Process'ler durmuyor
```bash
# Force kill
pkill -f diagnostic_planner
pkill -f localplanner
```

## 🔄 Workflow Önerileri

### Normal Kullanım
1. **Başlatma**: `./robotaxi_navigation_manager.sh -n`
2. **İzleme**: `./robotaxi_navigation_manager.sh -m`
3. **Durum**: `./robotaxi_navigation_manager.sh -s`
4. **Durdurma**: `./robotaxi_navigation_manager.sh -k`

### Debug Modu
1. **Tek node başlat**: `./robotaxi_navigation_manager.sh -d` veya `-l`
2. **Log'ları izle**: `./robotaxi_navigation_manager.sh -m`
3. **Test et**: ROS2 topic'leri kontrol et
4. **Temizle**: `./robotaxi_navigation_manager.sh -c`

### İnteraktif Kullanım
İnteraktif menü yeni kullanıcılar için en kolay yöntemdir:

```bash
./robotaxi_navigation_manager.sh  # Menü açılır
```

## 📝 Notlar

- Script, workspace dizininde (`/home/aaron/robotaxi_ws`) çalışmak üzere tasarlanmıştır
- Log dosyaları timestamp ile oluşturulur ve `latest` symlink'leri güncel dosyalara işaret eder
- PID dosyaları ile process tracking yapılır
- Multitail mevcut değilse otomatik olarak tail kullanılır
- Tüm output'lar renkli ve user-friendly'dir

## 🔗 İlgili Dosyalar

- `src/robotaxi_nav/nodes/localplanner.py` - Enhanced local planner with obstacle avoidance
- `src/robotaxi_nav/nodes/diagnostic_planner.py` - Diagnostic planner
- `src/robotaxi_nav/config/navigation_params.yaml` - Navigation parameters
- `src/robotaxi_nav/OBSTACLE_AVOIDANCE_README.md` - Obstacle avoidance documentation
- `src/robotaxi_nav/USAGE_GUIDE.md` - Detailed usage guide
