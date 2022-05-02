import json
from flask import Flask, request, jsonify

app = Flask(__name__,
        static_url_path='/',
        static_folder='static',
        template_folder='static')
app.config['JSON_AS_ASCII'] = False

@app.route('/', methods=['GET'])
def index():
    return app.send_static_file('index.html')

