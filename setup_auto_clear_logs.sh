#!/bin/bash

# Запрос папки у пользователя
read -p "Введите путь к папке с логами: " LOG_DIR

# Проверка существования папки
if [ ! -d "$LOG_DIR" ]; then
  echo "Папка не найдена: $LOG_DIR"
  exit 1
fi

# Запрос интервала удаления
echo "Как часто нужно удалять логи?"
echo "1) Каждый день"
echo "2) Каждые 2 дня"
echo "3) Кажую неделю"
read -p "Выберите вариант (1-3): " INTERVAL_CHOICE

# Определение cron-выражения по выбору
case "$INTERVAL_CHOICE" in
  1)
    CRON_SCHEDULE="0 3 * * *"          # Каждый день в 3 часа ночи
    ;;
  2)
    CRON_SCHEDULE="0 3 */2 * *"        # Каждые 2 дня в 3 часа ночи
    ;;
  3)
    CRON_SCHEDULE="0 3 * 0"            # Каждую неделю в воскресенье в 3 часа ночи
    ;;
  *)
    echo "Некорректный выбор, по умолчанию выбран вариант 'каждые 2 дня'."
    CRON_SCHEDULE="0 3 */2 * *"
    ;;
esac

# Путь к скрипту
SCRIPT_PATH="/usr/local/bin/auto_clear_logs.sh"

# Создаем скрипт очистки логов
cat << EOF > "$SCRIPT_PATH"
#!/bin/bash
find "$LOG_DIR" -type f -name "*.log" -delete
EOF

# Делаем его исполняемым
chmod +x "$SCRIPT_PATH"

# Проверка наличия задачи в crontab
(crontab -l 2>/dev/null | grep -F "$SCRIPT_PATH") && echo "Задача уже добавлена." || {
  # Добавляем задачу
  (crontab -l 2>/dev/null; echo "$CRON_SCHEDULE $SCRIPT_PATH") | crontab -
  echo "Задача добавлена в cron для автоматического удаления логов."
}
