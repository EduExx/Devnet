#APP 01

import pyotp #generates one-time passwords
import sqlite3 #database for username/passwords
import hashlib #secure hashes and message digests
import uuid #for creating universally unique identifiers
from flask import Flask, request
app = Flask(__name__) #Be sure to use two underscores before and after "name"
db_name = 'test.db'

@app.route('/signup/v1', methods=['POST'])
def signup_v1():
    conn = sqlite3.connect(db_name)
    c = conn.cursor()
    c.execute('''CREATE TABLE IF NOT EXISTS USER_PLAIN USERNAME TEXT PRIMARY KEY NOT NULL, PASSWORD TEXT NOT NULL);''')
    conn.commit()
    try:
        c.execute("INSERT INTO USER_PLAIN (USERNAME,PASSWORD) ", "VALUES ('{0}', '{1}')".format(request.form['username'], request.form['password']))
        conn.commit()
    except sqlite3.IntegrityError:
        return "username has been registered."
    print('username: ', request.form['username'], ' password: ', request.form['password'])
    return "signup success"
def verify_plain(username, password):
    conn = sqlite3.connect('test.db')
    c = conn.cursor()
    query = "SELECT PASSWORD FROM USER_PLAIN WHERE USERNAME = '{0}'".format(username)
    c.execute(query)
    records = c.fetchone()
    conn.close()
    if not records:
        return False
    return records[0] == password
if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, ssl_context='adhoc')