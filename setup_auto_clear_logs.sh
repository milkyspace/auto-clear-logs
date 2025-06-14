#!/bin/bash

# Запрос папки у пользователя
read -p "Введите путь к папке, в которой нужно очищать логи: " LOG_DIR

# Проверка, существует ли папка
if [ ! -d "$LOG_DIR" ]; then
  echo "Папка не найдена: $LOG_DIR"
  exit 1
fi

# Путь к скрипту
SCRIPT_PATH="/usr/local/bin/auto_clear_logs.sh"

# Создаем скрипт
cat << EOF > "$SCRIPT_PATH"
#!/bin/bash
# Скрипт для очистки логов в указанной папке
find "$LOG_DIR" -type f -name "*.log" -exec truncate -s 0 {} \;
EOF

# Делаем скрипт исполняемым
chmod +x "$SCRIPT_PATH"

# Проверяем, есть ли уже задача в crontab
(crontab -l 2>/dev/null | grep -F "$SCRIPT_PATH") && echo "Задача уже добавлена." || {
    # Добавляем задачу в crontab
    (crontab -l 2>/dev/null; echo "0 3 */2 * * $SCRIPT_PATH") | crontab -
    echo "Задача добавлена в cron: запуск каждые два дня в 3 часа ночи."
}
