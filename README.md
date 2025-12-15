# Docker Work5 - Course App

Проєкт містить FastAPI застосунок для курсу Docker & Kubernetes з підтримкою різних бекендів зберігання даних.

## Структура проєкту

```
.
├── apps/
│   └── course-app/          # Вихідний код застосунку
│       ├── src/
│       │   └── main.py      # Головний файл застосунку
│       ├── requirements.txt # Python залежності
│       └── README.md        # Детальна документація застосунку
├── Dockerfile               # Docker образ для course-app
├── docker-compose.yml       # Docker Compose конфігурація
├── docker-stack.yml         # Docker Swarm stack конфігурація
├── COMPOSE.md               # Детальна документація Compose файлу
└── SWARM.md                 # Інструкції для Docker Swarm
```

## Швидкий старт

### Запуск через Docker Compose

1. **Запуск застосунку:**
   ```bash
   docker-compose up -d
   ```

2. **Перегляд логів:**
   ```bash
   docker-compose logs -f
   ```

3. **Зупинка:**
   ```bash
   docker-compose down
   ```

4. **Зупинка з видаленням volumes:**
   ```bash
   docker-compose down -v
   ```

### Доступ до застосунку

- **Веб-інтерфейс:** http://localhost:8080
- **Health check:** http://localhost:8080/healthz
- **Readiness check:** http://localhost:8080/readyz
- **API Info:** http://localhost:8080/api/info

## Сервіси

### course-app
FastAPI застосунок, який надає:
- Веб-інтерфейс для роботи з повідомленнями
- API для управління повідомленнями та лічильниками
- CPU stress-тест для демонстрації HPA
- Health та readiness endpoints

**Порт:** 8080

**Volumes:**
- `appdata:/app/data` - Зберігає дані застосунку (SQLite база, лічильники) між перезапусками

**Healthcheck:** Перевіряє доступність через `/healthz` endpoint кожні 10 секунд

**Залежності:** Запускається після того, як Redis стане healthy

### redis
Redis сервер для зберігання даних застосунку.

**Порт:** 6379

**Volumes:**
- `redis-data:/data` - Зберігає дані Redis (лічильники відвідувань, повідомлення) між перезапусками

**Healthcheck:** Перевіряє доступність через `redis-cli ping` кожні 10 секунд

## Змінні середовища

Змінні середовища налаштовуються в `docker-compose.yml`:

| Змінна | Опис | Значення за замовчуванням |
|--------|------|---------------------------|
| `APP_MESSAGE` | Текст повідомлення на головній сторінці | "Welcome to the Course App" |
| `APP_STORE` | Вибір бекенду сховища | `redis` |
| `APP_REDIS_URL` | URL підключення до Redis | `redis://redis:6379/0` |

### Доступні значення для `APP_STORE`:
- `sqlite` - SQLite база даних (локальне зберігання)
- `redis` - Redis сервер (використовується в Docker Compose)
- `http` - HTTP мікросервіси (для Kubernetes)

## API Endpoints

- `GET /` - Головна сторінка з веб-інтерфейсом
- `GET /healthz` - Health check endpoint
- `GET /readyz` - Readiness check endpoint
- `GET /api/info` - Інформація про застосунок
- `GET /api/messages?limit=20` - Список повідомлень
- `POST /api/messages` - Додати повідомлення
- `GET /api/counter/{name}` - Отримати значення лічильника
- `GET /stress?seconds=10&background=true` - Запустити CPU stress-тест

## Персистентність даних

Лічильник відвідувань та інші дані зберігаються між перезапусками контейнерів через volumes:

- **redis-data** - Зберігає дані Redis (лічильники, повідомлення)
- **appdata** - Зберігає дані застосунку (SQLite база, якщо використовується SQLite режим)

Дані зберігаються навіть після `docker-compose down`. Для повного видалення даних використовуйте `docker-compose down -v`.

## Docker Swarm (опціонально)

Для розгортання в Docker Swarm режимі:

1. **Ініціалізуйте Swarm:**
   ```bash
   docker swarm init
   ```

2. **Зберіть образ (якщо потрібно):**
   ```bash
   docker build -t course-app:latest .
   ```

3. **Задеплойте stack:**
   ```bash
   docker stack deploy -c docker-stack.yml course-app-stack
   ```

4. **Перевірте статус:**
   ```bash
   docker stack services course-app-stack
   docker stack ps course-app-stack
   ```

Детальні інструкції дивіться в [SWARM.md](SWARM.md).

## Документація

- **[COMPOSE.md](COMPOSE.md)** - Детальний опис docker-compose.yml, healthchecks, volumes, залежностей
- **[SWARM.md](SWARM.md)** - Інструкції для розгортання в Docker Swarm режимі
- **[apps/course-app/README.md](apps/course-app/README.md)** - Детальна документація застосунку

## Локальний запуск (без Docker)

Детальні інструкції для локального запуску дивіться в [apps/course-app/README.md](apps/course-app/README.md).

## Технології

- **Python 3.12+**
- **FastAPI** - веб-фреймворк
- **Uvicorn** - ASGI сервер
- **Redis** - сховище даних
- **Docker & Docker Compose** - контейнеризація
- **Docker Swarm** - оркестрація контейнерів (опціонально)

