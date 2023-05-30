import pyotp #generates one-time passwords
import sqlite3 #database for username/passwords
import hashlib #secure hashes and message digests
import uuid #for creating universally unique identifiers
from flask import Flask, request
app = Flask(__name__) #Be sure to use two underscores before and after "name"
db_name = 'test.db'
@app.route('/')
def index():
    return 'Welcome to the hands-on lab for an evolution of password systems!'
if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, ssl_context='adhoc')