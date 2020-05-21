#!/bin/bash

############ PARAMETERS ############
BACKUP_DATA_DIR=/home/fenris/www/skillbox/backup
BACKUP_DIR=$BACKUP_DATA_DIR/$(date +%Y%m%d_%H%M%S)
DIRECTORIES="/home/fenris/www/skillbox/skill.store/ /home/fenris/www/skillbox/tmp/"
DB_USER=superuser
DB_PASS=H0o7M1n7
DB_NAME=store_db
DAYS_TO_STORE=30
############/PARAMETERS ############

echo "Started at: $(date)"
mkdir "$BACKUP_DATA_DIR"
mkdir "$BACKUP_DIR"

# Making and archivation DB dumps
#Для виртульаного сервера нужно прописывать путь /opt/lampp/bin/mysqldump или иной, при использовании других серверов
#Для реального достаточно вызвать mysqldump
/opt/lampp/bin/mysqldump --opt -u $DB_USER -p$DB_PASS --events $DB_NAME > "$BACKUP_DIR"/all.sql
#Создаем архив
# -c создание архива, x - извлечь
# j формат сжатия
# "$BACKUP_DIR"/all.sql.tbs - имя файла на выходе
# -C использовать указанную папку
# all.sql файл для архивирования
tar -cjf "$BACKUP_DIR"/all.sql.tbs -C "$BACKUP_DIR"/ all.sql
# Удаляем исходный файл после создания архива
rm "$BACKUP_DIR"/all.sql
echo "Database backup finished"

#Making directories backups
for DIRNAME in $DIRECTORIES; do
  #Выводим название папки для которой сейчас будет создаваться бэкап
  echo "Backupping $DIRNAME"
  #Переходим в нее
  cd "$DIRNAME" || exit
  FILENAME=$(echo "$DIRNAME" | sed 's/[\/]/\_/g' | sed 's/^\_\+\|\_|+$//g')
  #Последним аргументом указываем, что архивируем текущую директорию
  tar -cjf "$BACKUP_DIR"/"$FILENAME".tbz ./
done
echo "Directories backupping finished"

#Changing mode
chmod -R 700 "$BACKUP_DIR"

#Removing old backups
cd $BACKUP_DATA_DIR || exit
#Ищем в текущей папке всё типа директория и старше чем $DAYS_TO_STORE, передаем это в аргументы rm
find ./* -type d -mtime +$DAYS_TO_STORE | xargs -r rm -R
echo -e "Finished at: $(date)\n"
