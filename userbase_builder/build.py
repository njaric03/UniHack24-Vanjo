import threading
import time
import firebase_admin
import pandas as pd
import random
from firebase_admin import credentials, firestore, auth, storage


cred = credentials.Certificate("unihack24-vanjo-firebase-adminsdk-sy6dp-9f9e9c3288.json")
firebase_admin.initialize_app(cred)
print("Done")
db = firestore.client()

#users = pd.read_csv('./userbase_builder/users.csv')
#edges = pd.read_csv('./userbase_builder/teacher_student_connections.csv')
ID = {}
def sign_in_all():
    for index, row in users.iterrows():
        try:
            username = row['first_name']
            mail = row['email']
            password = username + "123"
            id = sign_in(mail, password)
            ID[row['user_id']] = id
        except Exception as e:
            print("Failed loading acc: " + row['user_id'])
    with open("copy.txt", "w") as file:
        for index, value in ID.items():
            file.write(format(index) + "," + value + "\n")
        
        
        
def sign_in(mail, passw):
    user = auth.create_user(email=mail, password=passw)
    return user.uid

reviews = {
    1: [
        "Terrible experience, I wouldn't recommend this at all.",
        "Very disappointing, the quality was way below expectations.",
        "Poor service and product. I wish I could get a refund.",
        "This was a complete waste of time and money.",
        "One of the worst experiences I've ever had. Do not buy this!"
    ],
    2: [
        "Not great, but I suppose it could be worse.",
        "Some aspects were okay, but overall not impressed.",
        "The product/service has major flaws that need to be addressed.",
        "Barely acceptable quality, not worth the price.",
        "Could use significant improvement in many areas."
    ],
    3: [
        "It was decent, but nothing special.",
        "Average quality, met my basic expectations.",
        "Some parts were good, while others were just okay.",
        "An okay experience, but there is room for improvement.",
        "Satisfied, but wouldn’t go out of my way to recommend it."
    ],
    4: [
        "Quite good overall, I’m happy with the outcome.",
        "Impressive, just a few minor issues here and there.",
        "A positive experience, and I would recommend it.",
        "Good quality and service, met my expectations well.",
        "Almost perfect, just a little shy of being excellent."
    ],
    5: [
        "Absolutely amazing, exceeded all my expectations!",
        "Flawless experience from start to finish.",
        "Excellent service/product, I highly recommend it!",
        "One of the best I’ve tried, couldn’t be happier.",
        "Superb quality, worth every penny. Will definitely return!"
    ]
}
reviews_list = {}
def add_reviews():
    review_collection = db.collection('review')
    i = 1
    for key, list in reviews.items():
        for value in list:
            review_data = {
                'text' : value,
                'rating' : key
            }
            review_collection.document(format(i)).set(review_data)
            print("Added document " + format(i))
            i += 1
            
def add_user_to_firestore():
    with open("copy.txt", "r") as file:
        for line in file:
            line = line.strip()
            values = line.split(",")
            ID[int(values[0])] = values[1]
    i = 1
    # for key, list in reviews.items():
    #     for value in list:
    #         reviews_list[value] = f"{i}"
    #         i+=1
    users_collection = db.collection('users')
    for index, row in users.iterrows():
        try:
            # learn = []
            # teach = []
            # if pd.notnull(row['learning_subject']) and row['learning_subject'] != '':    
            #     learn = [classes_collection.document(row['learning_subject'])]
            # if pd.notnull(row['teaching_subject']) and row['teaching_subject'] != '':
            #     teach = [classes_collection.document(row['teaching_subject'])]
            x = random.randint(1, 10)
            users_collection.document(ID[row['user_id']]).update({"avatar_id" : x})
            print("User updated!")
        except Exception as e:
            print("Failed loading acc: " + format(row['user_id']))