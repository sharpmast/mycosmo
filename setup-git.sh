
#!/bin/bash
set -e

echo "=== Підготовка готового сайту до публікації ==="

# Перевіряємо, що це корінь FLS-проєкту
if [ ! -f "package.json" ]; then
    echo "Помилка: package.json не знайдено."
    exit 1
fi

# Не допускаємо випадкового повторного налаштування Git
if [ -e ".git" ]; then
    echo "Помилка: Git уже ініціалізовано."
    echo "Цей скрипт призначений для нового репозиторію."
    exit 1
fi

# Вводимо адресу нового GitHub-репозиторію
read -r -p "Встав URL нового GitHub-репозиторію: " REPO_URL

if [ -z "$REPO_URL" ]; then
    echo "Помилка: URL не вказано."
    exit 1
fi

# Збираємо сайт
echo "=== Збираємо сайт ==="
npm run build

# Перевіряємо готову збірку
if [ ! -f "dist/index.html" ]; then
    echo "Помилка: dist/index.html не знайдено."
    exit 1
fi

# Копіюємо вміст dist у корінь проєкту
echo "=== Копіюємо готовий сайт ==="
cp -a dist/. .

# Ініціалізуємо Git
echo "=== Налаштовуємо Git ==="
git init -b main
git remote add origin "$REPO_URL"

# Додаємо тільки файли, що є у dist
while IFS= read -r -d '' item; do
    name="${item#dist/}"
    git add -A -- "$name"
done < <(find dist -mindepth 1 -maxdepth 1 -print0)

# Перевіряємо, що саме потрапить у перший коміт
echo "=== Файли для першого коміту ==="
git status --short

read -r -p "Створити коміт і завантажити сайт на GitHub? (y/n): " CONFIRM

if [[ "$CONFIRM" != "y" && "$CONFIRM" != "Y" ]]; then
    echo "Зупинено. Зміни залишилися локально."
    exit 0
fi

git commit -m "Initial website release"
git push -u origin main

echo "=== Готово! Сайт завантажено на GitHub ==="


# bash setup-git.sh
# https://github.com/sharpmast/mycosmo.git