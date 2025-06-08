# C++ and Python Bridge Interpreter

使用 Flex 和 Bison 建立的 C++/Python bridge interpreter

## 調用語法

```cpp
BRIDGE_CALL(function_name, parameter1, parameter2, ...) -> result_variable;
```

- `function_name`: Python 函數名稱
- `parameter1, parameter2, ...`: 參數列表
- `result_variable`: 接收結果的 C++ 變數名稱


## 專案結構

```
bridge_interpreter/
├── src/                        # 原始碼
│   ├── main.cpp                # 主程式
│   ├── bridge.l                # Flex
│   ├── bridge.y                # Bison
│   ├── bridge_interface.h      # C++ 橋接介面
│   └── bridge_interface.cpp
├── examples/                   # 範例檔案
│   ├── simple.cy
│   └── advanced.cy
├── build/                      # 編譯輸出
└── generated/                  # 生成的臨時檔案
```

## 運作原理

1. Flex/Bison 解析 `.cy` 檔案
2. 產生 `temp.cpp` 和 `temp.py` 
3. g++ 編譯 C++ 程式碼
4. C++ 程式調用 Python 函數

```
example.cy → [Flex/Bison] → temp.cpp + temp.py
                ↓
temp.cpp → [g++] → executable → [調用] → [python3 temp.py] → 結果
```

## 開發指令

```bash
# 編譯
make all

# 測試
make test

# 清理產生的檔案
make clean
```
