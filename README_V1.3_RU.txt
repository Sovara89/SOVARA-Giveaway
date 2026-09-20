SOVARA GIVEAWAY v1.3 — эксплуатация и тестирование

Добавлено:
- Журнал действий администраторов: баллы, блокировки, ЧС победителей, настройки, выбор победителя, завершение/новый раунд, управление админами и backups.
- Антиспам сообщений Twitch-чата: по умолчанию один засчитанный комментарий раз в 30 секунд на пользователя. Значение настраивается в админке; 0 отключает cooldown.
- Сообщения, попавшие под cooldown, всё равно сохраняются в истории чата, но баллы за них не начисляются.
- Тестовый раунд: число участников и длительность в минутах задаются из админки.
- Перед тестом сохраняется прогресс реального раунда. После сброса/завершения теста баллы, билеты и watchtime реального раунда восстанавливаются.
- Тестовые раунды никогда не попадают в публичный архив.
- Автобэкапы в DATA_DIR/backups примерно раз в сутки и перед опасными операциями. Хранятся последние 30 файлов.
- Кнопка «Создать backup сейчас» и отображение последней копии в админке.

На VPS DATA_DIR=/var/lib/sovara-giveaway, поэтому backups будут здесь:
/var/lib/sovara-giveaway/backups

Обновление:
cd /opt/sovara-giveaway
git fetch origin
git reset --hard origin/main
npm install --omit=dev
systemctl restart sovara-giveaway
systemctl --no-pager --full status sovara-giveaway

Twitch-службы v1.3:
- Админская Twitch-авторизация теперь использует Authorization Code Flow.
- Access/refresh token сохраняются в DATA_DIR/twitch-admin-auth.json (на VPS: /var/lib/sovara-giveaway/twitch-admin-auth.json).
- После restart/reboot сервер сам восстанавливает EventSub и watchtime и обновляет access token через refresh token.
- Для этого на VPS нужно один раз добавить TWITCH_CLIENT_SECRET в /etc/sovara-giveaway.env.
- Client Secret не загружать в GitHub и не присылать в чат.
