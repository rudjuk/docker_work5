# Docker Swarm розгортання Course App

## Передумови

1. Docker Swarm повинен бути ініціалізований
2. Менеджер-нода повинна бути доступна
3. Образ `course-app` повинен бути зібраний та доступний на всіх нодах

## Крок 1: Підготовка образу

### Варіант 1: Збірка образу на менеджер-ноді

```bash
# Зберіть образ
docker build -t course-app:latest .

# Або зберіть та завантажте в registry
docker build -t registry.example.com/course-app:latest .
docker push registry.example.com/course-app:latest
```

### Варіант 2: Використання registry

Оновіть `docker-stack.yml` та замініть:
```yaml
image: course-app:latest
```
на:
```yaml
image: registry.example.com/course-app:latest
```

## Крок 2: Ініціалізація Swarm (якщо ще не ініціалізовано)

```bash
# На менеджер-ноді
docker swarm init

# Якщо потрібно додати менеджер-ноди
docker swarm join-token manager

# Якщо потрібно додати worker-ноди
docker swarm join-token worker
```

## Крок 3: Створення overlay мережі (опціонально)

```bash
docker network create --driver overlay course-app-network
```

**Примітка:** Якщо використовується `docker-stack.yml`, мережа створиться автоматично.

## Крок 4: Розгортання stack

```bash
# Розгортання stack
docker stack deploy -c docker-stack.yml course-app-stack

# Перевірка статусу
docker stack services course-app-stack

# Перегляд деталей сервісів
docker stack ps course-app-stack
```

## Крок 5: Перевірка розгортання

```bash
# Список сервісів
docker service ls

# Деталі сервісу course-app
docker service ps course-app-stack_course-app

# Деталі сервісу redis
docker service ps course-app-stack_redis

# Логи сервісу
docker service logs course-app-stack_course-app

# Логи redis
docker service logs course-app-stack_redis
```

## Крок 6: Масштабування

```bash
# Збільшити кількість реплік course-app
docker service scale course-app-stack_course-app=3

# Або через stack файл (оновіть replicas та задеплойте знову)
docker stack deploy -c docker-stack.yml course-app-stack
```

## Керування stack

### Оновлення stack

```bash
# Оновіть docker-stack.yml, потім:
docker stack deploy -c docker-stack.yml course-app-stack
```

### Перегляд конфігурації

```bash
# Перевірка конфігурації stack
docker stack config docker-stack.yml
```

### Видалення stack

```bash
# Видалення stack (видалить всі сервіси, але не volumes!)
docker stack rm course-app-stack

# Видалення з volumes (обережно!)
docker stack rm course-app-stack
docker volume rm course-app-stack_redis-data course-app-stack_appdata
```

## Особливості Swarm конфігурації

### Course-app сервіс

- **Replicas:** 2 (можна змінити в `deploy.replicas`)
- **Update strategy:** Rolling update з 1 реплікою одночасно
- **Placement:** Тільки на worker нодах
- **Resources:** 
  - Limits: 1 CPU, 512MB RAM
  - Reservations: 0.25 CPU, 256MB RAM

### Redis сервіс

- **Replicas:** 1 (не рекомендується масштабувати без Redis Cluster)
- **Placement:** Тільки на manager ноді
- **Persistence:** AOF (Append Only File) увімкнено
- **Resources:**
  - Limits: 0.5 CPU, 256MB RAM
  - Reservations: 0.1 CPU, 128MB RAM

### Volumes

- **redis-data:** Зберігає дані Redis між перезапусками
- **appdata:** Зберігає дані застосунку (SQLite, якщо використовується)

### Мережа

- **Тип:** Overlay мережа для комунікації між нодами
- **Attachable:** Дозволяє підключати контейнери вручну

## Healthcheck в Swarm

Healthcheck автоматично використовується Swarm для:
- Визначення готовності сервісу
- Виконання rolling updates
- Автоматичного перезапуску нездорових контейнерів

## Troubleshooting

### Проблема: Сервіс не запускається

```bash
# Перевірте логи
docker service logs course-app-stack_course-app --tail 50

# Перевірте події
docker service ps course-app-stack_course-app --no-trunc
```

### Проблема: Образ не знайдено

```bash
# Перевірте, чи образ доступний на всіх нодах
docker node ls
docker service ps course-app-stack_course-app

# Якщо образ відсутній, завантажте його на всі ноди або використовуйте registry
```

### Проблема: Volumes не працюють

```bash
# Перевірте volumes
docker volume ls | grep course-app-stack

# Перевірте, чи volumes доступні на нодах
docker node inspect <node-id> | grep -A 10 Volumes
```

### Проблема: Мережа не створюється

```bash
# Перевірте мережі
docker network ls | grep course-app

# Створіть мережу вручну
docker network create --driver overlay course-app-network
```

## Масштабування та високодоступність

### Рекомендації

1. **Course-app:** Можна масштабувати до будь-якої кількості реплік
2. **Redis:** Для високодоступності використовуйте Redis Sentinel або Redis Cluster (потребує окремої конфігурації)

### Load Balancing

Swarm автоматично надає load balancing через ingress мережу. Всі запити до порту 8080 будуть розподілені між репліками course-app.

## Моніторинг

```bash
# Статистика використання ресурсів
docker stats $(docker ps -q --filter "name=course-app-stack")

# Події Swarm
docker events --filter 'service=course-app-stack_course-app'

# Healthcheck статус
docker service inspect course-app-stack_course-app --pretty | grep -A 10 Healthcheck
```

## Оновлення застосунку

```bash
# 1. Зберіть новий образ
docker build -t course-app:v2.0 .

# 2. Оновіть docker-stack.yml (змініть image tag)
# 3. Задеплойте stack
docker stack deploy -c docker-stack.yml course-app-stack

# Swarm автоматично виконає rolling update
```

## Безпека

1. **Secrets:** Для чутливих даних використовуйте Docker Secrets
2. **Networks:** Overlay мережа ізольована від інших stack
3. **Volumes:** Використовуйте encrypted volumes для production

## Приклад використання Secrets

```yaml
# Додайте в docker-stack.yml
secrets:
  redis_password:
    external: true

services:
  redis:
    secrets:
      - redis_password
    command: redis-server --requirepass file:/run/secrets/redis_password
```

Створення secret:
```bash
echo "my-secret-password" | docker secret create redis_password -
```

