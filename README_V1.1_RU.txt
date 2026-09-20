SOVARA GIVEAWAY v1.1 — Twitch scopes + исключение владельца канала

Что изменено:
- Аккаунт владельца канала SOVARA полностью исключён из начисления баллов, билетов, списка участников и пула победителей.
- Ручное начисление баллов владельцу через админку сервер тоже отклоняет.
- Обычный зритель при входе через Twitch запрашивает только scope `openid`.
- Расширенные Twitch-права вынесены в отдельную админскую авторизацию:
  `user:read:chat moderator:read:chatters`.
- В блоке «Статус Twitch» появилась кнопка «Подключить Twitch-службы» / «Переподключить Twitch-службы».
- После рестарта сервера служебный Twitch-токен находится только в памяти, поэтому администратору нужно снова нажать «Подключить Twitch-службы».
- Поля «балл / сообщение» и «балл / минуту» расширены.

ОБНОВЛЕНИЕ VPS
1. Загрузить содержимое архива в GitHub main.
2. На VPS:

cd /opt/sovara-giveaway
git fetch origin
git reset --hard origin/main
npm install --omit=dev
systemctl restart sovara-giveaway
systemctl --no-pager --full status sovara-giveaway

3. Открыть https://gift.sovara.ru и заново войти через Twitch.
4. Открыть «Админ» и нажать «Подключить Twitch-службы».
5. Подтвердить расширенные права Twitch только для аккаунта sovara_.

Старую переменную TWITCH_LOGIN_SCOPES можно оставить: v1.1 использует её как fallback только для админских Twitch-служб.
Живые данные /var/lib/sovara-giveaway/state.json обновлением не удаляются.
