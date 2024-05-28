import socket
import threading
from flask import Flask, request, render_template, send_from_directory
import os

# Flask Setup
app = Flask(__name__)
TARGET_ADDRESS = "http://example.com"
IMAGE_PATH = "image.jpg"
HOST = '0.0.0.0'
PORT = 9999

clients = []

@app.route('/', methods=['GET', 'POST'])
def index():
    global TARGET_ADDRESS
    if request.method == 'POST':
        TARGET_ADDRESS = request.form['target_address']
        image = request.files['image']
        if image:
            image.save(IMAGE_PATH)
    return render_template('index.html', target_address=TARGET_ADDRESS)

@app.route('/image.jpg')
def get_image():
    return send_from_directory('.', IMAGE_PATH)

def handle_client(client_socket):
    try:
        # Sende Zieladresse
        client_socket.sendall(TARGET_ADDRESS.encode())

        # Sende Bilddatei
        with open(IMAGE_PATH, 'rb') as f:
            while True:
                bytes_read = f.read(4096)
                if not bytes_read:
                    break
                client_socket.sendall(bytes_read)
    except Exception as e:
        print(f"Fehler beim Senden an den Client: {e}")
    finally:
        client_socket.close()

def start_server():
    server = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    server.bind((HOST, PORT))
    server.listen(5)
    print(f"[*] Server hört auf {HOST}:{PORT}")

    while True:
        client_socket, addr = server.accept()
        print(f"[*] Verbindung von {addr} akzeptiert")
        clients.append(client_socket)
        client_handler = threading.Thread(target=handle_client, args=(client_socket,))
        client_handler.start()

if __name__ == "__main__":
    threading.Thread(target=start_server).start()
    app.run(host='0.0.0.0', port=5000)

