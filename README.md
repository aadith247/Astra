# Astra
## A detailed report on Astra: 
[compilers_project_astra.pdf](https://github.com/user-attachments/files/26960510/compilers_project_astra.pdf)


# 🧠 Astra — Custom Programming Language Compiler

A mini-compiler for a Hindi-inspired programming language built using **Flex (Lex)** and **Bison (Yacc)**.  
SaathiLang supports core programming constructs and translates source code into **C**, compiles it using **GCC**, and executes it automatically.

---

## 🚀 Features

- 🔤 Lexical Analysis using Flex
- 📐 CFG-based Parsing using Bison
- 🌳 Abstract Syntax Tree (AST) construction
- 🔁 DFS-based AST traversal for code generation
- ⚙️ Automatic C code generation, compilation, and execution
- 🧩 Supports:
  - Variables (`number`, `shabd`)
  - Arithmetic expressions
  - Conditional statements (`agar`, `nahi to`)
  - Loops (`chalo ... times`)
  - Functions (`kaam`)
  - Return statements (`wapas`)
  - Print (`suno`)

---

---

## ⚙️ How It Works

1. **Lexer (Flex)** → Converts input into tokens  
2. **Parser (Bison)** → Applies CFG rules and builds AST  
3. **AST Traversal (DFS)** → Generates equivalent C code  
4. **Compilation** → GCC compiles generated C code  
5. **Execution** → Runs the compiled program  

---

## 🧪 Sample Code of Astra

```txt
number x = 5;
number y = 10;

agar (x < y) {
    suno("x is smaller");
}

chalo (3 times) {
    suno(x);
}
```
## 🔄 Generated C Code (in the backend) (Example)

```txt
#include <stdio.h>

int main() {
    int x = 5;
    int y = 10;

    if (x < y) {
        printf("x is smaller");
    }

    for(int i = 0; i < 3; i++) {
        printf("%d\n", x);
    }

    return 0;
}
```
## Output:
```txt
x is smaller
```

## 🛠️ Setup & Run

### 1. Install dependencies
```bash
sudo apt install flex bison gcc
```
### 2. Compile
```bash
bison -d parser.y
flex lexer.l
gcc lex.yy.c parser.tab.c -o astra
```

### 3. Run
```bash
./astra input.txt
```







