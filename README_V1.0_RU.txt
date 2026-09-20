SOVARA GIVEAWAY v1.0 — ОБНОВЛЕНИЕ VPS

Что добавлено:
- Публичный раздел «Архив розыгрышей».
- Для каждого завершённого раунда зритель видит: номер, дату, число участников, общее число билетов, победителя, число его билетов и ТИП приза.
- Публичный API не отдаёт Steam login, e-mail, Telegram, VK, friend code, ссылки/ID аккаунтов и другие данные профиля победителя.
- В админской истории у каждого завершённого раунда есть кнопка удаления. Нужна для тестовых розыгрышей.
- Удаление записи архива не затрагивает текущий активный раунд и пользователей.

ВАЖНО:
Живые данные на VPS находятся в /var/lib/sovara-giveaway и при обновлении кода не удаляются.

После загрузки содержимого этого архива в GitHub выполни на VPS:

cd /opt/sovara-giveaway
git fetch origin
git reset --hard origin/main
npm install --omit=dev
systemctl restart sovara-giveaway
systemctl --no-pager --full status sovara-giveaway
curl -sS http://127.0.0.1:4177/api/status

Проверка публичного архива:
curl -sS http://127.0.0.1:4177/api/archive
