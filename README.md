# Docker Work4 - Course App

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
└── docker-compose.yml       # Docker Compose конфігурація
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

### redis
Redis сервер для зберігання даних застосунку.

**Порт:** 6379

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

## Локальний запуск (без Docker)

Детальні інструкції для локального запуску дивіться в [apps/course-app/README.md](apps/course-app/README.md).

## Технології

- **Python 3.12+**
- **FastAPI** - веб-фреймворк
- **Uvicorn** - ASGI сервер
- **Redis** - сховище даних
- **Docker & Docker Compose** - контейнеризація

