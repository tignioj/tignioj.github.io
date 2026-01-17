---
date: 2026-01-17T09:11:45+08:00
lastmod: 2026-01-17T09:11:45+08:00
categories:
  - 编程杂谈
  - 嵌入式
  - ESP32
title: ESP32在PlatformIO中使用ESPAsyncWebServer库
draft: "false"
tags:
  - ESP32
  - holocubic
  - PlatformIO
series: []
---
## 编辑配置文件
直接修改lib_deps,会自动下载依赖库 
```
lib_deps =
  ESP32Async/AsyncTCP
  ESP32Async/ESPAsyncWebServer
```

这里放一个完整的配置文件 `platformio.ini`

```ini
; PlatformIO Project Configuration File
;
;   Build options: build flags, source filter
;   Upload options: custom upload port, speed and extra flags
;   Library options: dependencies, extra library storages
;   Advanced options: extra scripting
;
; Please visit documentation for the other options and examples
; https://docs.platformio.org/page/projectconf.html

[platformio]
default_envs = env:httptest

[env:base]
platform = espressif32@~6.5.0
; platform = espressif32@~6.4.0
; platform = espressif32 @ ~3.5.0
; platform = espressif32 @ ~5.2.0
; platform = espressif32
board = pico32
framework = arduino

monitor_filters = esp32_exception_decoder
monitor_speed = 115200
; monitor_flags = 
; 	--eol=CRLF
; 	--echo
; 	--filter=esp32_exception_decoder
build_flags =
    ; ${env.build_flags}
    ; -D LV_FONT_MONTSERRAT_10=1
    -fPIC -Wreturn-type -Werror=return-type
    ; -D CONFIG_ARDUINO_LOOP_STACK_SIZE=10000

upload_port = COM5
; upload_port = COM6
upload_speed = 921600
board_build.partitions = partitions-no-ota.csv
board_build.f_cpu = 240000000L
board_build.f_flash = 80000000L
board_build.flash_mode = qio


[env:httptest]
extends = env:base
build_flags =
  ${env.build_flags}
    -O0
    -D ARDUHAL_LOG_LEVEL=1
lib_compat_mode = strict
lib_ldf_mode = chain
lib_deps =
  ESP32Async/AsyncTCP
  ESP32Async/ESPAsyncWebServer
```

### 示例测试

```cpp
#include <WiFi.h>
#include <AsyncTCP.h>
#include <ESPAsyncWebServer.h>

// WiFi配置
const char* ssid = "SSID";
const char* password = "PASSWORD";

// 创建AsyncWebServer对象，监听80端口
AsyncWebServer server(80);

void setup() {
  Serial.begin(115200);
  
  // 连接WiFi
  WiFi.begin(ssid, password);
  while (WiFi.status() != WL_CONNECTED) {
    delay(1000);
    Serial.println("Connecting to WiFi...");
  }
  
  Serial.println("WiFi connected!");
  Serial.print("IP Address: ");
  Serial.println(WiFi.localIP());

  // 基本路由配置
  
  // 处理根路径GET请求
  server.on("/", HTTP_GET, [](AsyncWebServerRequest *request){
    String html = "<html><head><title>ESP32 Server</title></head>";
    html += "<body><h1>Hello from ESP32!</h1>";
    html += "<p>Free Heap: " + String(ESP.getFreeHeap()) + " bytes</p>";
    html += "<p>IP Address: " + WiFi.localIP().toString() + "</p>";
    html += "</body></html>";
    request->send(200, "text/html", html);
  });

  // 处理带参数的GET请求
  server.on("/greet", HTTP_GET, [](AsyncWebServerRequest *request){
    String name = "World";
    if (request->hasParam("name")) {
      name = request->getParam("name")->value();
    }
    request->send(200, "text/plain", "Hello " + name + "!");
  });

  // 处理POST请求
  server.on("/data", HTTP_POST, [](AsyncWebServerRequest *request){
    String message = "No data received";
    
    if (request->hasParam("message", true)) {
      message = request->getParam("message", true)->value();
    }
    
    request->send(200, "application/json", 
      "{\"status\":\"success\",\"message\":\"" + message + "\"}");
  });

  // 处理文件上传
  server.on("/upload", HTTP_POST, [](AsyncWebServerRequest *request){
    request->send(200, "text/plain", "Upload Complete");
  }, 
  [](AsyncWebServerRequest *request, const String& filename, 
     size_t index, uint8_t *data, size_t len, bool final){
    // 处理上传的文件块
    Serial.printf("Upload: %s, index: %d, len: %d\n", 
                  filename.c_str(), index, len);
  });

  // 处理404错误
  server.onNotFound([](AsyncWebServerRequest *request){
    request->send(404, "text/plain", "Not Found");
  });

  // 启动服务器
  server.begin();
  Serial.println("HTTP server started");
}

void loop() {
  // 不需要在loop中做任何事情
  // AsyncWebServer在后台运行
}
```


## 错误排查
报错:
```
In file included from src/app/httptest.cpp:3:0:
.pio/libdeps/httptest/ESPAsyncWebServer/src/ESPAsyncWebServer.h:8:26: fatal error: lwip/tcpbase.h: No such file or directory
compilation terminated.
```
说明你的platform版本太低！检查这个字段版本是否正确
```
[env:base]
platform = espressif32@~6.5.0
```