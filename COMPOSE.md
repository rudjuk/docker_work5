# Docker Compose конфігурація для Course App

## Опис файлу docker-compose.yml

Цей файл визначає мультиконтейнерну конфігурацію для застосунку Course App, що складається з двох сервісів:

### Сервіси

#### 1. course-app
**Призначення:** Головний FastAPI застосунок

**Характеристики:**
- **Порт:** 8080 (маппінг на хост)
- **Build:** Збирається з Dockerfile в кореневій директорії
- **Container name:** `course-app`

**Змінні середовища:**
- `APP_MESSAGE` - Привітальне повідомлення (за замовчуванням: "Welcome to the Course App")
- `APP_STORE` - Бекенд сховища даних (`redis`, `sqlite`, або `http`)
- `APP_REDIS_URL` - URL підключення до Redis (`redis://redis:6379/0`)
- `APP_DB_PATH` - Шлях до SQLite бази даних (`/app/data/data.sql`)

**Volumes:**
- `appdata:/app/data` - Том для збереження даних застосунку (SQLite база, лічильники тощо) між перезапусками контейнера

**Healthcheck:**
- **Тест:** Перевірка доступності `/healthz` endpoint через Python urllib
- **Інтервал:** 10 секунд
- **Таймаут:** 5 секунд
- **Повтори:** 3
- **Start period:** 10 секунд (час на ініціалізацію перед початком перевірок)

**Залежності:**
- Залежить від сервісу `redis` з умовою `service_healthy` - застосунок запуститься тільки після того, як Redis стане healthy

**Restart policy:** `unless-stopped` - автоматичний перезапуск при падінні

#### 2. redis
**Призначення:** Redis сервер для зберігання даних застосунку

**Характеристики:**
- **Image:** `redis:7-alpine` (легковісний Alpine-based образ)
- **Порт:** 6379 (маппінг на хост)
- **Container name:** `course-app-redis`

**Volumes:**
- `redis-data:/data` - Том для збереження даних Redis між перезапусками контейнера

**Healthcheck:**
- **Тест:** Команда `redis-cli ping` для перевірки доступності Redis
- **Інтервал:** 10 секунд
- **Таймаут:** 3 секунди
- **Повтори:** 3
- **Start period:** 5 секунд

**Restart policy:** `unless-stopped`

### Volumes

#### redis-data
- **Тип:** `local` driver
- **Призначення:** Зберігає дані Redis (лічильники відвідувань, повідомлення) між перезапусками контейнера
- **Персистентність:** Дані зберігаються навіть після видалення контейнера (поки том не видалений)

#### appdata
- **Тип:** `local` driver
- **Призначення:** Зберігає дані застосунку (SQLite база даних, якщо використовується SQLite режим) між перезапусками контейнера
- **Персистентність:** Дані зберігаються навіть після видалення контейнера (поки том не видалений)

### Порядок запуску та залежності

1. **Redis запускається першим** - не має залежностей
2. **Healthcheck Redis** - перевіряє доступність Redis через `redis-cli ping`
3. **Course-app чекає** - використовує `depends_on` з умовою `service_healthy`, тому запускається тільки після того, як Redis стане healthy
4. **Healthcheck Course-app** - перевіряє доступність застосунку через `/healthz` endpoint

### Збереження даних між перезапусками

**Лічильник відвідувань зберігається між перезапусками через:**

1. **Redis режим (поточний):**
   - Дані зберігаються в томі `redis-data`
   - Redis автоматично персистує дані в `/data` директорії
   - Лічильник зберігається в Redis ключі `counters:visits`

2. **SQLite режим (альтернативний):**
   - Дані зберігаються в томі `appdata`
   - SQLite база знаходиться в `/app/data/data.sql`
   - Лічильник зберігається в таблиці `counters` з ключем `visits`

### Команди для роботи

```bash
# Запуск сервісів
docker-compose up -d

# Перегляд логів
docker-compose logs -f

# Перегляд статусу сервісів
docker-compose ps

# Перевірка healthcheck статусу
docker-compose ps --format json | jq '.[] | {name: .Name, health: .Health}'

# Зупинка сервісів
docker-compose down

# Зупинка з видаленням volumes (видалить всі дані!)
docker-compose down -v

# Перезапуск конкретного сервісу
docker-compose restart course-app

# Перебудова та запуск
docker-compose up -d --build
```

### Перевірка збереження даних

1. Запустіть застосунок: `docker-compose up -d`
2. Відкрийте http://localhost:8080 та зробіть кілька відвідувань
3. Зупиніть контейнери: `docker-compose down`
4. Запустіть знову: `docker-compose up -d`
5. Перевірте, що лічильник відвідувань зберігся

### Troubleshooting

**Проблема:** Course-app не запускається
- Перевірте, чи Redis healthy: `docker-compose ps`
- Перевірте логи: `docker-compose logs course-app`

**Проблема:** Дані не зберігаються
- Перевірте, чи volumes створені: `docker volume ls`
- Перевірте, чи volumes примонтовані: `docker-compose config`

**Проблема:** Healthcheck не проходить
- Перевірте логи сервісу: `docker-compose logs course-app`
- Перевірте доступність endpoint вручну: `curl http://localhost:8080/healthz`

