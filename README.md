# C++ and Python Bridge Interpreter

使用 Flex 和 Bison 建立的 C++/Python bridge interpreter，實現 C++ 與 Python 程式碼的混合。透過自定義的 .cy 檔案格式，讓 C++ 程式能直接調用 Python 函數並取得回傳值，支援多種參數型別的自動轉換。

## 組員分工

- **馮宥崴**：詞法分析器設計與實作 (bridge.l)、測試範例設計
- **蕭宇翔**：語法分析器設計與實作 (bridge.y)、程式碼生成邏輯  
- **巫侑霖**：橋接介面實作 (bridge_interface.cpp/h)、主程式與建置系統 (main.cpp, Makefile)

## 環境需求

- Linux 
- g++ （C++11）
- flex
- bison
- python3

## 使用指令

```bash
# 編譯
make all

# 執行測試（預設 simple.cy）
make run

# 執行指定檔案
make run FILE=examples/advanced.cy

# 清理產生的檔案
make clean
```

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

## 技術實現

編譯器採用三階段處理：Flex 識別不同語言區塊，Bison 生成對應的 C++ 和 Python 程式碼，最後透過橋接介面使用 system() 調用執行 Python 函數。支援的參數型別包括整數、浮點數和字串，並具備自動型別推斷和轉換機制。
