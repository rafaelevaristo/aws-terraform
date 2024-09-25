#!/bin/bash
yum update -y
yum install -y python3 git
pip3 install flask

# Create a simple Flask app
echo "from flask import Flask
app = Flask(__name__)
@app.route('/')
def hello_world():
    return 'Hello, World from Flask on AWS EC2! And other stuff!!!'
if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)" > /home/ec2-user/app.py

# Run the Flask app
nohup python3 /home/ec2-user/app.py &