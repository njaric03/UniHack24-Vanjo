import threading
import time
import firebase_admin
from firebase_admin import credentials, firestore, storage
from knowledge_graph.UserGraph import UserGraph

def initialize_firebase():
    cred = credentials.Certificate("../resources/credentials/unihack24-vanjo-firebase-adminsdk-sy6dp-9f9e9c3288.json")
    firebase_admin.initialize_app(cred)
    return firestore.client()

def add_user(user_graph : UserGraph, doc_id : str, doc_data : dict):
    user_graph.add_user(doc_id, doc_data)
    return

def modify_user(doc_id, doc_data):
    # Define the logic for modifying a user here
    return

def delete_user(user_graph : UserGraph, doc_id):
    user_graph.remove_user(doc_id)
    return

def find_cycle(user_graph : UserGraph, doc_id):
    cycle = user_graph.find_best_cycle(doc_id)
    image = user_graph.draw_cycle(doc_id)

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
            delete_user(change.document.id)
            print("DELETED!")
            print(change.document.to_dict())
        callback_done.set()
    callback_done.set()

def monitor_changes(users_collection):
    while True:
        if callback_done.wait(timeout=1):
            callback_done.clear()
            print("Waiting for next change...")
        else:
            print("No changes detected.")

if __name__ == "__main__":
    db = initialize_firebase()
    user_graph = UserGraph.load_from_file('../resources/userbase/userbase_graph.pkl')
    callback_done = threading.Event()
    initial_snapshot = True

    users = db.collection('users')
    users.on_snapshot(on_snapshot)

    monitor_changes(users)
