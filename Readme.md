# Скрипты для управления бэкапами
Максимально упрощенный механизм создания бэкапа (снапшота) директории и синхронизации репозитория снапшотов между директориями.

Зависимости:
- [restic](https://restic.net/) - создание снапшотов
- [rsync](https://rsync.samba.org/) - синхронизация директорий

Дополнительно:
- [lnav](https://lnav.org/) - просмотр логов

## Предварительная подготовка
1. Перед выполнением скрипта следует инициализировать репозиторий:
```bash
restic init --repo <repository_dir>
```
2. В директории репозитория следует создать директорию `logs`:
```bash
mkdir <repository_dir>/logs
```
3. В директории репозитория следует создать файл `pass.txt` содержащий пароль (да, не самый безопасный подход, стоит сделать иначе) к репозиторию указанный на шаге 1:
```bash
vim <repository_dir>/pass.txt
```

## Создание снапшота
Лучше всего для разных исходных директорий создавать различные репозитории.
```bash
bash ./go-restic.sh <repository_dir> <working_files_dir>
```

## Синхронизация бэкапа с внешним средством хранения
Никто не мешает запускать скрипт несколько раз с различными целевыми директориями, например, на разных носителях.
```bash
bash ./go-rsync.sh <repository_dir> <backup_dir>
```

## Логгирование
Логи создания снапшотов сохраняются в директории `<repository_dir>/logs` с именем дня исполнения скрипта.

## Примеры
Вот так можно поставить в cron. Целевых директорий для синхронизации может быть несколько.
```bash
WORK_DIR="/Users/macuser/Documents/PostNauka" &&\
REPO_DIR="/Users/macuser/Backups/Work/Restic/Documents/PostNauka" &&\
BACK_DIR="/Volumes/external_SSD/Backups/Restic/Documents" &&\
bash ./go-restic.sh $REPO_DIR $WORK_DIR &&\
bash ./go-rsync.sh $REPO_DIR $BACK_DIR
```
