# app.py

from flask import Flask

app = Flask(__name__)

@app.route('/')
def hello():
    return 'Hello, World! abc'

@app.route('/health')
def health():
    return 'Hello, World from health endpoint.'

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=8000)

