---
date: 2024-01-24T07:55:12+08:00
lastmod: 2024-01-24T07:55:12+08:00
categories:
  - 编程杂谈
  - Python
title: Python的selenium用ddddocr做验证码识别
draft: "false"
tags:
  - 验证码
series:
---

```python
from selenium import webdriver
from selenium.webdriver.common.by import By
from PIL import Image  
from io import BytesIO


driver = webdriver.Chrome()
driver.maximize_window()


def checkCode(img):  
    img = Image.open(BytesIO(img))  
    ocr = ddddocr.DdddOcr()  
    code_text = ocr.classification(img)  
    img.save(code_text + ".png", "PNG")  # 保存验证码到本地，可选
    print("验证码识别为:{code_text}".format(code_text=code_text))  
    return code_text
# 浏览器打开页面
driver.get("https://example.com")
# 查找验证码元素，并调用截图
elem_img_code = driver.find_element(By.ID, "login_idCode").screenshot_as_png  

# 验证码识别  
code_text = checkCode(elem_img_code)
```

需要注意的是，如果浏览器窗口没有完整显示验证码图片，`screenshot_as_png`会截不完整验证码图片，因此需要调用`driver.maximize_window()` 使得验证码完整显示。