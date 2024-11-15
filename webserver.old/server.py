from http.server import BaseHTTPRequestHandler
from routes.main import routes
import os
import sys
import subprocess

class Server(BaseHTTPRequestHandler):
  allowed_addresses = [
    '162.213.197.114',
    '173.231.224.141',
    '103.93.199.34',
  ]
  def do_HEAD(self):
    return

  def do_GET(self):
    a=self.client_address[0]
    print(a)
    if a in self.allowed_addresses:
       self.respond()
    else:
       msg = "Access Prohibited"
       self.wfile.write(bytes(msg, "UTF-8"))
 
  def do_POST(self):
    return

  def handle_http(self, status, content_type):
    self.send_response(status)
    self.send_header('Content-type', content_type)
    #self.end_headers()
    route_content = routes[self.path]
    print(self.path)
    if self.path == "/":
        result = route_content
    else:
        result = subprocess.run(route_content,shell=True,text=True,capture_output=True)
        result = result.stdout
    self.end_headers()
    return bytes(result, "UTF-8")

  def respond(self):
    content = self.handle_http(200, 'text/html')
    self.wfile.write(content)
