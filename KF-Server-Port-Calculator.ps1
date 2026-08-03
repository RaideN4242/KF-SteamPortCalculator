# KF-Server-Port-Calculator.ps1
# Скрипт для расчета портов Killing Floor 1 на основе основного игрового порта

Clear-Host
Write-Host "========================================================" -ForegroundColor Cyan
Write-Host "    KF-Server-Port-Calculator - Расчет портов KF1" -ForegroundColor Yellow
Write-Host "========================================================" -ForegroundColor Cyan
Write-Host ""

# Константы (дефолтные порты из документации)
$DEFAULT_GAME_PORT = 7707
$DEFAULT_MASTER_PORT = 28852
$DEFAULT_STEAM_PORT = 20560
$DEFAULT_OLD_QUERY_PORT = 7717

# Запрос основного порта у пользователя
do {
    $USER_PORT = Read-Host "Укажите основной игровой порт вашего сервера KF (например, 9507)"
    
    # Проверка, что введено число
    if ($USER_PORT -match "^\d+$") {
        $USER_PORT = [int]$USER_PORT
        if ($USER_PORT -ge 1 -and $USER_PORT -le 65535) {
            $validInput = $true
        } else {
            Write-Host "Ошибка: Порт должен быть в диапазоне 1-65535. Попробуйте снова." -ForegroundColor Red
            $validInput = $false
        }
    } else {
        Write-Host "Ошибка: Пожалуйста, введите только число. Попробуйте снова." -ForegroundColor Red
        $validInput = $false
    }
} while (-not $validInput)

# Выполнение расчетов
Write-Host ""
Write-Host "Выполняется расчет для основного порта: $USER_PORT..." -ForegroundColor Green
Start-Sleep -Milliseconds 300

# Основные расчеты по формулам
$masterPort = ($DEFAULT_MASTER_PORT - $DEFAULT_GAME_PORT) + $USER_PORT
$steamPort = ($DEFAULT_STEAM_PORT - $DEFAULT_GAME_PORT) + $USER_PORT
$queryPort = $USER_PORT + 1          # +1 для игрового Query Port
$steamQueryPort = $USER_PORT + 10    # +10 для Steam Query Port
$oldQueryPort = $DEFAULT_OLD_QUERY_PORT + ($USER_PORT - $DEFAULT_GAME_PORT)

# WebAdmin порт (стандартный, редко меняют)
$webAdminPort = 8075

# Вывод результатов
Write-Host ""
Write-Host "========================================================" -ForegroundColor Cyan
Write-Host "            РЕЗУЛЬТАТЫ РАСЧЕТА ПОРТОВ" -ForegroundColor Yellow
Write-Host "========================================================" -ForegroundColor Cyan
Write-Host ""

# Форматированный вывод в таблице
Write-Host " Назначение порта" -ForegroundColor White -NoNewline
Write-Host " " -NoNewline
Write-Host "Порт" -ForegroundColor White -NoNewline
Write-Host " " -NoNewline
Write-Host "Протокол" -ForegroundColor White -NoNewline
Write-Host " " -NoNewline
Write-Host "Примечание" -ForegroundColor White
Write-Host "----------------------------------------------------------------" -ForegroundColor Gray

# Функция для вывода строки с цветами
function Write-PortLine {
    param(
        [string]$name,
        [int]$port,
        [string]$protocol,
        [string]$note = ""
    )
    
    $nameFormatted = $name.PadRight(25)
    $portFormatted = $port.ToString().PadRight(10)
    $protocolFormatted = $protocol.PadRight(12)
    
    Write-Host $nameFormatted -NoNewline -ForegroundColor White
    Write-Host $portFormatted -NoNewline -ForegroundColor Green
    Write-Host $protocolFormatted -NoNewline -ForegroundColor Cyan
    
    if ($note -ne "") {
        Write-Host $note -ForegroundColor Gray
    } else {
        Write-Host ""
    }
}

# Вывод строк таблицы
Write-PortLine -name "Игровой порт (Game Port)" -port $USER_PORT -protocol "UDP" -note "Для подключения в игре"
Write-PortLine -name "Query Port (в игре)" -port $queryPort -protocol "UDP" -note "+1 к основному порту"
Write-PortLine -name "Steam Query Port" -port $steamQueryPort -protocol "UDP" -note "+10 к основному порту"
Write-PortLine -name "Мастер-сервер (Master)" -port $masterPort -protocol "TCP+UDP" -note "Для доступа к мастер-серверу"
Write-PortLine -name "Steam Port" -port $steamPort -protocol "UDP" -note "Для работы с Steam бэкендом"
Write-PortLine -name "WebAdmin" -port $webAdminPort -protocol "TCP" -note "Стандартный порт (не меняется)"

Write-Host "----------------------------------------------------------------" -ForegroundColor Gray

# Дополнительная информация
Write-Host ""
Write-Host "========================================================" -ForegroundColor Cyan
Write-Host "         ДОПОЛНИТЕЛЬНАЯ ИНФОРМАЦИЯ" -ForegroundColor Yellow
Write-Host "========================================================" -ForegroundColor Cyan
Write-Host ""

# Генерация строки для файла KillingFloor.ini
Write-Host "✏️  Настройка в файле KillingFloor.ini:" -ForegroundColor White
Write-Host "   В секции [IpDrv.UdpGamespyQuery] измените:" -ForegroundColor Gray
Write-Host "   OldQueryPortNumber=$oldQueryPort" -ForegroundColor Green
Write-Host "   (было 7717, стало $oldQueryPort)" -ForegroundColor Gray
Write-Host ""

# Формулы для проверки
Write-Host "📐 Использованные формулы:" -ForegroundColor White
Write-Host "   Мастер-сервер: ($DEFAULT_MASTER_PORT - $DEFAULT_GAME_PORT) + $USER_PORT = $masterPort" -ForegroundColor Gray
Write-Host "   Steam порт:   ($DEFAULT_STEAM_PORT - $DEFAULT_GAME_PORT) + $USER_PORT = $steamPort" -ForegroundColor Gray
Write-Host "   Steam Query:  $USER_PORT + 10 = $steamQueryPort" -ForegroundColor Gray
Write-Host "   Query:        $USER_PORT + 1 = $queryPort" -ForegroundColor Gray

# Проверка на конфликт с WebAdmin
if ($USER_PORT -eq $webAdminPort) {
    Write-Host ""
    Write-Host "⚠️  ВНИМАНИЕ: Ваш игровой порт совпадает с портом WebAdmin ($webAdminPort)!" -ForegroundColor Red
    Write-Host "   Рекомендуется изменить порт WebAdmin во избежание конфликтов." -ForegroundColor Red
}

# Проверка диапазона портов
if ($USER_PORT -lt 1024) {
    Write-Host ""
    Write-Host "⚠️  Примечание: Порт $USER_PORT относится к привилегированным портам (1-1023)." -ForegroundColor Yellow
    Write-Host "   На некоторых системах для их использования требуются права администратора." -ForegroundColor Yellow
}

Write-Host ""
Write-Host "========================================================" -ForegroundColor Cyan
Write-Host "       Расчет завершен. Нажмите любую клавишу для выхода..." -ForegroundColor White
Write-Host "========================================================" -ForegroundColor Cyan

# Ожидание нажатия клавиши
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
