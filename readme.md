# 🌐 Assembly WebServer - Minimal HTTP Server

This repository implements a **basic web server in assembly** language, demonstrating low-level networking by handling basic HTTP requests on `localhost:80`.

## 🗂️ Contents

- **`index.html`**: Main HTML page served by the server.
- **`405.html`**: Custom 405 error page, displayed when users make unsupported requests (e.g., POST).
- **`code.S`**: Assembly source code implementing the web server.
- **`images/`**: Contains image assets like `dragon2_image.png`, which are currently loaded from the internet rather than locally.

## 🌟 Features

- **Simple GET Requests**: Only requested pages (e.g., `index.html`) are rendered. Non-existent files, like `nonexistant.html`, will not load.
- **Basic Error Handling**: Unsupported POST requests will redirect users to the **405 error page**.

## 🚀 Usage

1. **Compile** the assembly code:
   ```bash
   nasm -f elf64 code.S -o code.o
   ld code.o -o a.out
   ```
   
2. **Run** the server:
   ```bash
   ./a.out
   ```

3. Access it on **`http://localhost`**.

## 📜 License

This project is open for modification and use—ideal for learning low-level web server mechanics! 🎉
