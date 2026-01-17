---
date: 2026-01-17T08:21:43+08:00
lastmod: 2026-01-17T08:55:00+08:00
categories:
  - 编程杂谈
  - 嵌入式
  - ESP32
title: ESP32在PlatformIO中使用SimpleFTP库
draft: "false"
tags:
  - FTP
  - ESP32
  - PlatformIO
  - holocubic
series: []
---
## 下载SimpleFTP库到本地

https://github.com/xreef/SimpleFTPServer
注意，是直接下整个源码，而不是Release，因为目前最新的Release是3.0.0，而源码已经更新到3.0.2，这个版本之前的库都会报错。报错内容如下，简单来说就是类型转换异常，所以我们要用3.0.2版本。解决方案来源于这个issue: https://github.com/xreef/SimpleFTPServer/issues/90
```
lib/SimpleFTPServer/FtpServer.cpp: In member function 'bool FtpServer::openFile(const char*, uint8_t)': lib/SimpleFTPServer/FtpServer.cpp:2797:49: error: invalid conversion from 'uint8_t {aka unsigned char}' to 'const char*' [-fpermissive] file = STORAGE_MANAGER.open( path, readType ); ^
```



## 在PlatformIO中导入该库
### 下载完成后，放到你的工程文件lib目录下具体结构如下
- 项目根目录
	- lib
		- SimpleFTP3.0.2
	- src
		- main.cpp
	- platform.io

### 修改platform.io工程文件
```ini
[env:ftptest]
lib_deps = ./lib/SimpleFTPServer3.0.2
```

这里放一个一个完整的工程文件
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
default_envs = env:ftptest

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


[env:ftptest]
extends = env:base
build_flags =
  ${env.build_flags}
    -O0
    -D ARDUHAL_LOG_LEVEL=1
lib_deps = ./lib/SimpleFTPServer3.0.2

```
## 编写代码

### 编写实例代码
你可以在SimpleFTP的examples中找到示例 `Arduino_esp32_SD.ino`
```cpp
/*
 * Simple FTP Server Example with SD Card on ESP32
 *
 * AUTHOR: Renzo Mischianti
 * URL: https://www.mischianti.org
 *
 * DESCRIPTION:
 * This example demonstrates how to use the SimpleFTPServer library
 * with an ESP32 and an SD card module. The ESP32 connects to a WiFi network
 * and initializes an FTP server for file transfers.
 *
 * FEATURES:
 * - WiFi connection to local network
 * - SD card initialization for file storage
 * - FTP server setup for file uploads and downloads
 *
 * https://www.mischianti.org/2020/02/08/ftp-server-on-esp8266-and-esp32
 *
 */

#include <WiFi.h>
#include <SimpleFTPServer.h>
#include <SPI.h>
#include <SD.h>

// WiFi credentials
const char* WIFI_SSID = "<YOUR-SSID>";    		// Replace with your WiFi SSID
const char* WIFI_PASSWORD = "<YOUR-PASSWD>";    // Replace with your WiFi password

// SD card chip select pin
const int CHIP_SELECT_PIN = SS;               // Default SS pin for SPI

// FTP server instance
FtpServer ftpServer;

void setup() {
  // Initialize Serial Monitor
  Serial.begin(9600);
  while (!Serial) {
    // Wait for serial port to connect (required for native USB ports)
  }

  // Connect to WiFi network
  Serial.println("Connecting to WiFi...");
  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }
  Serial.println("\nWiFi connected!");
  Serial.printf("Connected to: %s\n", WIFI_SSID);
  Serial.printf("IP Address: %s\n", WiFi.localIP().toString().c_str());

  // Wait for a short delay before initializing SD card
  delay(1000);

  // Initialize SD card
  Serial.print("Initializing SD card...");
  while (!SD.begin(CHIP_SELECT_PIN)) {
    delay(500);
    Serial.print(".");
  }
  Serial.println("\nSD card initialized successfully!");

  // Start FTP server with username and password
  ftpServer.begin("user", "password"); // Replace with your desired FTP credentials
  Serial.println("FTP server started!");
}

void loop() {
  // Handle FTP server operations
  ftpServer.handleFTP(); // Continuously process FTP requests
}

```

我们这里要修改一下SD卡的宏定义

结构目录
- src
	- main.cpp
	- common.h

common.h这里放你的SD卡引脚宏
```cpp
// RGB
#define RGB_LED_PIN 27

// SD_Card
#define SD_SCK 14
#define SD_MISO 26
#define SD_MOSI 13
#define SD_SS 15

// MUP6050
#define IMU_I2C_SDA 32
#define IMU_I2C_SCL 33
```


main.cpp
```cpp
/*
 * Simple FTP Server Example with SD Card on ESP32
 *
 * AUTHOR: Renzo Mischianti
 * URL: https://www.mischianti.org
 *
 * DESCRIPTION:
 * This example demonstrates how to use the SimpleFTPServer library
 * with an ESP32 and an SD card module. The ESP32 connects to a WiFi network
 * and initializes an FTP server for file transfers.
 *
 * FEATURES:
 * - WiFi connection to local network
 * - SD card initialization for file storage
 * - FTP server setup for file uploads and downloads
 *
 * https://www.mischianti.org/2020/02/08/ftp-server-on-esp8266-and-esp32
 *
 */

#include <WiFi.h>
#include <SimpleFTPServer.h>
#include <SPI.h>
#include <SD.h>
#include "common.h"

// WiFi credentials
const char* WIFI_SSID = "xxx";    		// Replace with your WiFi SSID
const char* WIFI_PASSWORD = "xxx";    // Replace with your WiFi password

// SD card chip select pin
const int CHIP_SELECT_PIN = SD_SS;               // Default SS pin for SPI

// FTP server instance
FtpServer ftpServer;

void setup() {
  // Initialize Serial Monitor
  Serial.begin(115200);
  while (!Serial) {
    // Wait for serial port to connect (required for native USB ports)
  }

  // Connect to WiFi network
  Serial.println("Connecting to WiFi...");
  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }
  Serial.println("\nWiFi connected!");
  Serial.printf("Connected to: %s\n", WIFI_SSID);
  Serial.printf("IP Address: %s\n", WiFi.localIP().toString().c_str());

  // Wait for a short delay before initializing SD card
  delay(1000);

  // Initialize SD card
  Serial.print("Initializing SD card...");


    SPIClass *sd_spi = new SPIClass(HSPI);          // another SPI
    sd_spi->begin(SD_SCK, SD_MISO, SD_MOSI, SD_SS); // Replace default HSPI pins
    while (!SD.begin(SD_SS, *sd_spi, 80000000))        // SD-Card SS pin is 15
    {
        Serial.println("Card Mount Failed");
        delay(1000);
    }
        uint8_t cardType = SD.cardType();
    if (cardType == CARD_NONE)
    {
        Serial.println("No SD card attached");
        return;
    }

    Serial.print("SD Card Type: ");
    if (cardType == CARD_MMC)
    {
        Serial.println("MMC");
    }
    else if (cardType == CARD_SD)
    {
        Serial.println("SDSC");
    }
    else if (cardType == CARD_SDHC)
    {
        Serial.println("SDHC");
    }
    else
    {
        Serial.println("UNKNOWN");
    }

    uint64_t cardSize = SD.cardSize() / (1024 * 1024);
    Serial.printf("SD Card Size: %lluMB\n", cardSize);

  Serial.println("\nSD card initialized successfully!");

  SD.mkdir("/ftp_root");


  

  // Start FTP server with username and password
  ftpServer.begin("user", "password"); // Replace with your desired FTP credentials
  Serial.println("FTP server started!");
}

void loop() {
  // Handle FTP server operations
  ftpServer.handleFTP(); // Continuously process FTP requests
}

```

### 修改源码FtpServerKey.h
找到这行
```cpp
// esp32 configuration
	#define DEFAULT_STORAGE_TYPE_ESP32 		STORAGE_FFAT
```
修改为
```cpp
#define DEFAULT_STORAGE_TYPE_ARDUINO        STORAGE_SD
```

## 连接ftp服务
编译并上传到ESP32后，串口输出成功连接上WiFi，可以用[FileZilla](https://filezilla-project.org/)作为客户端连接，
这个太简单就不具体讲了。


### 错误排查
- 连接上后，如果发现目录是空白，串口报错`[E][vfs_api.cpp:22] open(): File system is not mounted 。` 说明你没有连接成功。你需要检查你的FtpServerKey.h有没有修改宏`#define DEFAULT_STORAGE_TYPE_ARDUINO        STORAGE_SD`
- 编译不通过，报错类型转换错误`invalid conversion from 'uint8_t {aka unsigned char}' to 'const char*`  则检查你的SimpleFTP版本是不是3.0.2以上

### 参考教程
- [FTP server on esp8266 and esp32](https://mischianti.org/ftp-server-on-esp8266-and-esp32/)
