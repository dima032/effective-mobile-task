#!/bin/bash

PROCESS_NAME="test"
API_URL="https://test.com/monitoring/test/api"
LOG_FILE="/var/log/monitoring.log"
PID_FILE="/tmp/test_process_last.pid"

# Функция логирования с датой
log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
}

# Фиксируем текущий PID процесса
CURRENT_PID=$(pgrep -x "$PROCESS_NAME" | head -n 1)

if [[ -z "$CURRENT_PID" ]]; then
    # Если процесс не запущен, завершаем скрипт
    exit 0
fi

# Сравниваем с предыдущим PID, проверяем перезапуск
if [[ -f "$PID_FILE" ]]; then
    LAST_PID=$(cat "$PID_FILE")
    # Если старый PID существует и не равен текущему — процесс был перезапущен
    if [[ -n "$LAST_PID" && "$LAST_PID" != "$CURRENT_PID" ]]; then
        log_message "Process '$PROCESS_NAME' was restarted. Old PID: $LAST_PID, New PID: $CURRENT_PID"
    fi
fi

# Сохраняем текущий PID для следующей проверки
echo "$CURRENT_PID" > "$PID_FILE"

# Отправка запроса на сервер
if ! curl -s -f -o /dev/null "$API_URL"; then
    # Если сервер недоступен или возвращает ошибку, логируем это событие
    log_message "Monitoring server unavailable or returned error: $API_URL"
fi

exit 0