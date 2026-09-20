SOVARA Giveaway v1.3 — постоянное подключение Twitch-служб

Почему раньше приходилось нажимать «Переподключить Twitch-службы»:
- служебный access token хранился только в памяти Node.js;
- systemctl restart / обновление / reboot очищали его;
- Implicit OAuth не выдаёт refresh token.

Что изменено в v1.3:
- админская авторизация переведена на Twitch Authorization Code Flow;
- access + refresh token сохраняются вне GitHub в DATA_DIR/twitch-admin-auth.json;
- на VPS это /var/lib/sovara-giveaway/twitch-admin-auth.json;
- после restart/reboot сервер автоматически восстанавливает EventSub + watchtime;
- при истечении access token сервер сам получает новый через refresh token.

ОДИН РАЗ ПОСЛЕ ОБНОВЛЕНИЯ:
1. Twitch Developer Console -> твое приложение SOVARA Giveaway -> Manage.
2. Создай Client Secret.
3. НЕ присылай Client Secret в чат и НЕ клади его в GitHub.
4. На VPS выполни:

read -rsp "Twitch Client Secret: " TWITCH_SECRET; echo
sed -i '/^TWITCH_CLIENT_SECRET=/d' /etc/sovara-giveaway.env
printf 'TWITCH_CLIENT_SECRET=%s\n' "$TWITCH_SECRET" >> /etc/sovara-giveaway.env
unset TWITCH_SECRET
chmod 600 /etc/sovara-giveaway.env
systemctl restart sovara-giveaway

5. Зайди на gift.sovara.ru -> Админ -> «Подключить Twitch-службы».
6. Подтверди Twitch один последний раз.

После этого кнопка нужна только если Twitch-доступ был отозван, изменён пароль/секрет или приложение отключено в настройках Twitch.
