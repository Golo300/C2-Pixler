import socket
import time

# Server-Einstellungen
SERVER_HOST = '127.0.0.1'
SERVER_PORT = 9999

def receive_data(client_socket):
    try:
        # Empfange Zieladresse
        target_address = client_socket.recv(1024).decode()
        print(f"Zieladresse empfangen: {target_address}")

        # Empfange Bilddatei
        with open('target_image.jpg', 'wb') as f:
            while True:
                bytes_read = client_socket.recv(4096)
                if not bytes_read:
                    break
                f.write(bytes_read)
        print("Bilddatei empfangen und gespeichert als 'target_image.jpg'")
    except Exception as e:
        print(f"Fehler beim Empfangen von Daten: {e}")
    finally:
        pass
        #client_socket.close()

if __name__ == "__main__":
    while True:
        client_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        client_socket.connect((SERVER_HOST, SERVER_PORT))
        receive_data(client_socket)
        time.sleep(10)