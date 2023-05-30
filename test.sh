#!/bin/bash

# Função para iniciar o servidor
start_server() {
    echo "Iniciando o servidor..."
    python password-evolution.py &
    echo "Servidor iniciado."
    read -p "Pressione Enter para voltar ao menu principal."
}

# Função para desligar o servidor
stop_server() {
    echo "Desligando o servidor..."
    pkill -f "python password-evolution.py"
    echo "Servidor desligado."
    read -p "Pressione Enter para voltar ao menu principal."
}

# Função para verificar o status do servidor
check_status() {
    echo "Verificando o status do servidor..."
    pgrep -f "python password-evolution.py" &> /dev/null
    if [[ $? -eq 0 ]]; then
        echo "O servidor está em execução."
    else
        echo "O servidor não está em execução."
    fi
    read -p "Pressione Enter para voltar ao menu principal."
}

# Função para criar usuário com hash
create_user_with_hash() {
    read -p "Digite o nome de usuário: " username
    read -s -p "Digite a senha: " password
    echo
    echo "Criando usuário com hash..."
    python - <<EOF
import sqlite3
import hashlib

db_name = 'test.db'
username = "$username"
password = "$password"

conn = sqlite3.connect(db_name)
c = conn.cursor()
c.execute('''CREATE TABLE IF NOT EXISTS USER_HASH (USERNAME TEXT PRIMARY KEY NOT NULL, HASH TEXT NOT NULL);''')
conn.commit()
hash_value = hashlib.sha256(password.encode()).hexdigest()
c.execute("INSERT INTO USER_HASH (USERNAME, HASH) VALUES (?, ?)", (username, hash_value))
conn.commit()
conn.close()
EOF
    echo "Usuário criado com hash."
    read -p "Pressione Enter para voltar ao menu principal."
}

# Função para criar usuário sem hash
create_user_without_hash() {
    read -p "Digite o nome de usuário: " username
    read -s -p "Digite a senha: " password
    echo
    echo "Criando usuário sem hash..."
    python - <<EOF
import sqlite3

db_name = 'test.db'
username = "$username"
password = "$password"

conn = sqlite3.connect(db_name)
c = conn.cursor()
c.execute('''CREATE TABLE IF NOT EXISTS USER_PLAIN (USERNAME TEXT PRIMARY KEY NOT NULL, PASSWORD TEXT NOT NULL);''')
conn.commit()
c.execute("INSERT INTO USER_PLAIN (USERNAME, PASSWORD) VALUES (?, ?)", (username, password))
conn.commit()
conn.close()
EOF
    echo "Usuário criado sem hash."
    read -p "Pressione Enter para voltar ao menu principal."
}

# Função para fazer login com hash
login_with_hash() {
    read -p "Digite o nome de usuário: " username
    read -s -p "Digite a senha: " password
    echo
    echo "Fazendo login com hash..."
    python - <<EOF
import sqlite3
import hashlib

db_name = 'test.db'
username = "$username"
password = "$password"

conn = sqlite3.connect(db_name)
c = conn.cursor()
query = "SELECT HASH FROM USER_HASH WHERE USERNAME = ?"
c.execute(query, (username,))
records = c.fetchone()
conn.close()
if records and records[0] == hashlib.sha256(password.encode()).hexdigest():
    print("Login bem-sucedido.")
else:
    print("Nome de usuário ou senha inválido(s).")
EOF
    read -p "Pressione Enter para voltar ao menu principal."
}

# Função para fazer login sem hash
login_without_hash() {
    read -p "Digite o nome de usuário: " username
    read -s -p "Digite a senha: " password
    echo
    echo "Fazendo login sem hash..."
    python - <<EOF
import sqlite3

db_name = 'test.db'
username = "$username"
password = "$password"

conn = sqlite3.connect(db_name)
c = conn.cursor()
query = "SELECT PASSWORD FROM USER_PLAIN WHERE USERNAME = ?"
c.execute(query, (username,))
records = c.fetchone()
conn.close()
if records and records[0] == password:
    print("Login bem-sucedido.")
else:
    print("Nome de usuário ou senha inválido(s).")
EOF
    read -p "Pressione Enter para voltar ao menu principal."
}

# Função para exibir o menu principal
show_menu() {
    echo "===== Menu ====="
    echo "1. Iniciar servidor"
    echo "2. Desligar servidor"
    echo "3. Verificar status do servidor"
    echo "4. Criar usuário com hash"
    echo "5. Criar usuário sem hash"
    echo "6. Fazer login com hash"
    echo "7. Fazer login sem hash"
    echo "8. Sair"
    echo "================"
}

# Loop do menu
while true; do
    show_menu
    read -p "Escolha uma opção: " option

    case $option in
        1) 
            start_server
            ;;
        2) 
            stop_server
            ;;
        3) 
            check_status
            ;;
        4) 
            create_user_with_hash
            ;;
        5) 
            create_user_without_hash
            ;;
        6) 
            login_with_hash
            ;;
        7) 
            login_without_hash
            ;;
        8) 
            break
            ;;
        *) 
            echo "Opção inválida. Tente novamente."
            ;;
    esac
done
