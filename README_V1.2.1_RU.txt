SOVARA GIVEAWAY v1.2.1

Изменено:
- Иконка сайта заменена на выбранный синий подарок с оранжевым бантом.
- Добавлены favicon.png и favicon.ico.
- Та же иконка используется рядом с логотипом SOVARA GIVEAWAY в шапке.
- К ссылкам favicon добавлен cache-busting, чтобы браузеры быстрее забыли старую иконку.

Обновление VPS после загрузки файлов в GitHub:

cd /opt/sovara-giveaway
git fetch origin
git reset --hard origin/main
npm install --omit=dev
systemctl restart sovara-giveaway
