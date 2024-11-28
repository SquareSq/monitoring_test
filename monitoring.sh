#!/bin/bash

# Конфигурация
PROCESS_NAME="test"
LOG_FILE="/var/log/monitoring.log"
MONITOR_URL="https://test.com/monitoring/test/api"
CHECK_INTERVAL=60

# Функция записи в лог
log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
}

# Сохраняем идентификатор процесса на начальном этапе
PROCESS_PID=$(pgrep -x "$PROCESS_NAME")

# Основной цикл мониторинга
while true; do
    
    # Проверяем запущен ли процесс
    if pgrep -x "$PROCESS_NAME" > /dev/null; then
        # Процесс запущен
        log_message "Процесс '$PROCESS_NAME' запущен."

        # Проверка состояния процесса
        if [[ "$PROCESS_PID" != "$(pgrep -x "$PROCESS_NAME")" ]]; then
            # Процесс был перезапущен
            log_message "Процесс '$PROCESS_NAME' был перезапущен."
        fi
    fi

    # Обращаемся к URL для проверки состояния сервера
    RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" "$MONITOR_URL")

    # Проверяем код ответа
    if [ "$RESPONSE" -ne 200 ]; then
        # Сервер мониторинга недоступен
        log_message "Сервер мониторинга недоступен. Код ответа: $RESPONSE"
    else
        log_message "Сервер мониторинга доступен. Код ответа: $RESPONSE"
    fi

    # Сохраняем идентификатор процесса на следующую итерацию
    PROCESS_PID=$(pgrep -x "$PROCESS_NAME")
    
    # Ждем указанное время перед следующей проверкой
    sleep "$CHECK_INTERVAL"
done