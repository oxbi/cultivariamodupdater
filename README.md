# Cultivaria mod updater / Обновлялка Cultivaria
n**Easiest: open the [install page](https://oxbi.github.io/cultivariamodupdater/) with an English / Русский switch and a download button.**

Click a language to open or close it / Нажмите на язык, чтобы открыть или закрыть:

<details open>
<summary><h2>English</h2></summary>

Keeps your Cultivaria modpack up to date with one double-click.

### Step by step (do this once)

1. Open the **Releases** page: https://github.com/oxbi/cultivariamodupdater/releases/latest
2. Under **Assets**, click **`Cultivaria-Updater.zip`** to download it.
   - Ignore the two other entries there, **"Source code (zip)"** and **"Source code (tar.gz)"**. GitHub adds them automatically; you don't need them.
3. Open your Downloads folder, right-click `Cultivaria-Updater.zip`, choose **Extract All...**, then click **Extract**.
4. Open the new `Cultivaria-Updater` folder. It contains 3 files; keep them together.
5. **Close Minecraft / TLauncher.**
6. Double-click **`Update-Cultivaria.bat`**.
   - If Windows shows "Windows protected your PC", click **More info**, then **Run anyway**.
7. A black window shows what is being downloaded. When it says **"Updated to pack ..."** or **"Already up to date"**, press any key. You're done: start the game as usual.

### Every update after that

When you are told there is an update: close Minecraft and double-click `Update-Cultivaria.bat` again (the same file from step 4; there is no need to download anything). The updater also updates itself.

### What it changes and what it doesn't

- **Changes:** the pack's mods, the Cultivaria mod file and the pack's config files in `%APPDATA%\.minecraft`. Replaced files are backed up first to `.minecraft\cultivaria-update-backup`.
- **Never touches:** your settings and keybinds, saves, screenshots, resource packs, and mods you added yourself. Your shader and minimap settings are kept too.
- If a download or a check fails, it stops with a red "UPDATE FAILED" message and changes nothing. Send that message to the host.

### Different Minecraft folder?

The updater expects the normal TLauncher folder (`%APPDATA%\.minecraft`). If yours is elsewhere, open a terminal in the updater folder and run:
`Update-Cultivaria.bat -GameDir "D:\path\to\.minecraft"`

---
*For the host:* once a release is published, the repo root holds `manifest.json` and `files/` (the current pack).

</details>

<details>
<summary><h2>Русский</h2></summary>

Обновляет вашу сборку Cultivaria одним двойным кликом.

### Пошагово (делается один раз)

1. Откройте страницу **Releases**: https://github.com/oxbi/cultivariamodupdater/releases/latest
2. В разделе **Assets** нажмите на **`Cultivaria-Updater.zip`**, чтобы скачать его.
   - Два других пункта, **«Source code (zip)»** и **«Source code (tar.gz)»**, не трогайте. GitHub добавляет их сам, они вам не нужны.
3. Откройте папку «Загрузки», нажмите на `Cultivaria-Updater.zip` правой кнопкой мыши, выберите **«Извлечь всё...»**, затем нажмите **«Извлечь»**.
4. Откройте появившуюся папку `Cultivaria-Updater`. В ней 3 файла; держите их вместе.
5. **Закройте Minecraft / TLauncher.**
6. Дважды щёлкните по файлу **`Update-Cultivaria.bat`**.
   - Если Windows пишет «Windows защитила ваш компьютер», нажмите **«Подробнее»**, затем **«Выполнить в любом случае»**.
7. В чёрном окне будет видно, что скачивается. Когда появится надпись **«Updated to pack ...»** или **«Already up to date»**, нажмите любую клавишу. Готово: запускайте игру как обычно.

### Все следующие обновления

Когда вам сообщат, что вышло обновление: закройте Minecraft и снова дважды щёлкните по `Update-Cultivaria.bat` (это тот же файл из шага 4, ничего скачивать заново не нужно). Сама обновлялка тоже обновляется автоматически.

### Что она меняет, а что нет

- **Меняет:** моды сборки, файл мода Cultivaria и конфиги сборки в папке `%APPDATA%\.minecraft`. Заменяемые файлы сначала копируются в резервную папку `.minecraft\cultivaria-update-backup`.
- **Никогда не трогает:** ваши настройки и управление, сохранения миров, скриншоты, ресурспаки и моды, которые вы добавили сами. Настройки шейдеров и миникарты тоже сохраняются.
- Если скачивание или проверка файла не удались, программа остановится с красным сообщением «UPDATE FAILED» и ничего не изменит. Отправьте это сообщение хозяину сервера.

### Другая папка Minecraft?

Обновлялка ищет обычную папку TLauncher (`%APPDATA%\.minecraft`). Если у вас она в другом месте, откройте терминал в папке обновлялки и выполните:
`Update-Cultivaria.bat -GameDir "D:\путь\к\.minecraft"`

---
*Для хозяина сервера:* после публикации релиза в корне репозитория лежат `manifest.json` и `files/` (текущая сборка).

</details>
