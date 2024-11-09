import threading
import time
import firebase_admin
from firebase_admin import credentials, firestore, storage

cred = credentials.Certificate("unihack24-vanjo-firebase-adminsdk-sy6dp-9f9e9c3288.json")
firebase_admin.initialize_app(cred)
db = firestore.client()

def add_user(doc_id, doc_data):
    return
    
def modify_user(doc_id, doc_data):
    return

def delete_user(doc_id, doc_data):
    return

callback_done = threading.Event()
initial_snapshot = True
def on_snapshot(col_snapshot, changes, read_time):
    global initial_snapshot
    if initial_snapshot:
        initial_snapshot = False
        return
    for change in changes:
        if change.type.name == 'ADDED':
            print("ADDED!")
            print(change.document.to_dict())
            add_user(change.document.id, change.document.to_dict())
        elif change.type.name == 'MODIFIED':
            modify_user(change.document.id, change.document.to_dict())
            print("MODIFIED!")
            print(change.document.to_dict())
        elif change.type.name == 'REMOVED':
            delete_user(change.document.id, change.document.to_dict())
            print("DELETED!")
            print(change.document.to_dict())
        callback_done.set()
    callback_done.set()

users = db.collection('users')
users.on_snapshot(on_snapshot)

while True:
    if callback_done.wait(timeout=1):
        callback_done.clear()
        print("Waiting for next change...")
    else:
        print("No changes detected.")