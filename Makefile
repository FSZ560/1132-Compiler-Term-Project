CC = g++
CFLAGS = -Wall -std=c++11
BUILD_DIR = build
GEN_DIR = generated

TARGET = $(BUILD_DIR)/bridge_interpreter
OBJECTS = $(BUILD_DIR)/main.o $(BUILD_DIR)/bridge_interface.o $(BUILD_DIR)/lex.yy.o $(BUILD_DIR)/bridge.tab.o

all: setup $(TARGET)

setup:
	@mkdir -p $(BUILD_DIR) $(GEN_DIR)

$(TARGET): $(OBJECTS)
	$(CC) -o $@ $^

$(BUILD_DIR)/%.o: src/%.cpp $(BUILD_DIR)/bridge.tab.h
	$(CC) $(CFLAGS) -I $(BUILD_DIR) -I src -c $< -o $@

$(BUILD_DIR)/lex.yy.o: $(BUILD_DIR)/lex.yy.c
	$(CC) $(CFLAGS) -I $(BUILD_DIR) -c $< -o $@

$(BUILD_DIR)/bridge.tab.o: $(BUILD_DIR)/bridge.tab.c
	$(CC) $(CFLAGS) -c $< -o $@

$(BUILD_DIR)/lex.yy.c: src/bridge.l $(BUILD_DIR)/bridge.tab.h
	flex -o $@ $<

$(BUILD_DIR)/bridge.tab.c $(BUILD_DIR)/bridge.tab.h: src/bridge.y
	bison -d -o $(BUILD_DIR)/bridge.tab.c $<

test: $(TARGET)
	./$(TARGET) examples/advanced.cy

clean:
	rm -f $(BUILD_DIR)/*
	rm -f $(GEN_DIR)/*