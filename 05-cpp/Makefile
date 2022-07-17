CC = g++
CFLAGS = -Wall -Wextra -std=c++20
SAMPLE = sample.txt
INPUT = input.txt

test: main
	@echo "Running sample"
	@./main $(SAMPLE)

run: main
	@echo "Running input"
	@./main $(INPUT)

clean:
	@rm main

main: main.cpp
	@echo "Compiling..."
	@$(CC) $(CFLAGS) main.cpp -o main
