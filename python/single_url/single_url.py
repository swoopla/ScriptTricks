#!/usr/bin/env python3

import secrets
import string
import sqlite3
import datetime

DATABASE = 'downloads.db'

# Create a database table to store download links
def init_db():
    with sqlite3.connect(DATABASE) as con:
        con.execute('CREATE TABLE IF NOT EXISTS downloads (url TEXT PRIMARY KEY, expiry INTEGER)')

# Initialize the database
init_db()

# Generate a random URL
def generate_url(length=10):
    alphabet = string.ascii_letters + string.digits
    return ''.join(secrets.choice(alphabet) for _ in range(length))

# Insert a new download link into the database
def insert_download(url, expiry):
    with sqlite3.connect(DATABASE) as con:
        con.execute('INSERT INTO downloads (url, expiry) VALUES (?, ?)', (url, expiry))

# Get the expiry date and time for a download link
def get_expiry(url):
    with sqlite3.connect(DATABASE) as con:
        cur = con.cursor()
        cur.execute('SELECT expiry FROM downloads WHERE url = ?', (url,))
        row = cur.fetchone()
        if row is not None:
            return datetime.datetime.fromtimestamp(row[0])
    return None

# Check if a download link has expired
def is_expired(url):
    expiry = get_expiry(url)
    if expiry is not None:
        return datetime.datetime.now() > expiry
    return True

# Get the number of downloads for a download link
def get_count(url):
    with sqlite3.connect(DATABASE) as con:
        cur = con.cursor()
        cur.execute('SELECT COUNT(*) FROM downloads WHERE url = ? AND expiry > ?', (url, datetime.datetime.now().timestamp()))
        return cur.fetchone()[0]

# Generate a new download link
def generate_download_link(expiry_days=7):
    url = generate_url()
    expiry = datetime.datetime.now() + datetime.timedelta(days=expiry_days)
    insert_download(url, expiry.timestamp())
    return url

# Example usage
url = generate_download_link(expiry_days=7)
download_url = f'https://www.example.com/download/{url}'
print('Download URL:', download_url)
print('Is expired:', is_expired(url))
print('Download count:', get_count(url))
