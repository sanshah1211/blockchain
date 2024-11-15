from flask import Flask
import os
import sys
import subprocess
import threading

app = Flask(__name__)

def  runc(command):
    try:
        command1 = "bash /home/ubuntu/webserver/scripts/" + command + ".sh"
        #print(command1)
        result = subprocess.run(command1,shell=True,text=True,capture_output=True)
        result = result.stdout
        return result
    except subprocess.CalledProcessError as e:
        print(e.output)


def bg_task_transaction():
    thread = threading.Thread(target=runc("transaction"))
    thread.start()

@app.route('/')
def index():
    return "Welcome To Validator API"

  
@app.route('/information')
def information():
    return runc("information")

@app.route('/healthcheck')
def healthcheck():
    return runc("healthcheck")

@app.route('/status')
def status():
    return runc("status")

@app.route('/transaction')
def transaction():
    return bg_task_transaction()

@app.route('/deploy')
def deploy():
    return runc("deploy")

@app.route('/check')
def check():
    return runc("balance")

@app.route('/download')
def download():
    return runc("fetch")

    
if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port='8000')
