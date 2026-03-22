import random
import json
import os

# # Logger
# # print("Hello world!!")
# # datatypes
# ## string
# print("This is String")

# ## integer
# print(123)

# ## float
# print(123.456)

# ## boolean
# print(True)
# print(False)

# ## list
# print([1, 2, 3, 4, 5])

# ## tuple
# print((1, 2, 3, 4, 5))

# ## dictionary
# print({"name": "John", "age": 30, "city": "New York"})

# ## set
# print({1, 2, 3, 4, 5})

# ## none
# print(None)

# # Variable




# while secret_number:
#     number = int(input("Nhập số : "))
#     if number < secret_number:
#         print("Nhỏ hơn rồi")
#         continue
#     elif number > secret_number:
#         print("Lớn hơn rồi")
#         continue
#     else:
#         print("chúc mừng")
#         break

def replay_action():
    replay = input("Bạn có muốn chơi lại không? (yes/no) ").strip().lower()

    match replay:
        case "yes":
            return True
        case "no":
            return False
        case _:
            print("Nhập sai, thử lại!")
            return replay_action()

    


all_records = {}
all_records_json = []

def logger(all_records, name, history_failed, history_record):
    print("Các số đoán sai:", history_failed)
    print(f"{name} đoán mất {history_record} lần")

    print("===============Bảng xếp hạng===============")
    
    for player, score in all_records.items():
        print(f"{player}: {score} lần")

def random_number():
    return random.randint(1, 50)


# action file txt
def save_data_to_file_txt(name,score):
    with open("record.txt","a",encoding="utf-8") as f:
        f.write(f"{name}: {score} lần \n")
def read_data_to_file_txt():
    global all_records
    try:
        with open("record.txt","r",encoding="utf-8") as f:
            for line in f:
                line = line.strip()
                if not line: continue

                parts = line.split(":")
                if len(parts) == 2:
                    name = parts[0].strip()
                    score_str = parts[1].split(" lần")
                    score = int(score_str[0])
                    all_records[name] = score
    except FileNotFoundError:
        print("Không tìm thấy file !!!")

# action file json
filename = "record-json.json"
def save_data_to_file_json(name,score):
    if os.path.exists(filename) and os.path.getsize(filename) > 0:
        with open(filename, "r") as f:
            try:
                all_records = json.load(f)
            except json.JSONDecodeError:
                all_records = [] # Reset if file is corrupted
    else:
        all_records = []

    new_entry = {"name": name, "score": score}
    all_records.append(new_entry)

    with open(filename, "w") as f:
        json.dump(all_records, f, indent=4)
        print(f"Successfully saved record for {name}!")

def read_data_to_file_json():
    
    # Check if file is empty first
    if os.path.exists(filename) and os.path.getsize(filename) == 0:
        print("The file is empty! Add some data (like {} ) to it.")
        return {}

    with open(filename, "r") as f:
        content = f.read()
        print(f"File content: '{content}'") # See what's actually inside
        
        # Now try to parse the string we just read
        all_records_json = json.loads(content) 
        return all_records_json
   


def tro_choi_doan_so():
    secret_number = random_number()
    name = str(input("Nhập tên của bạn : "))
    if not name:
        print("Vui lòng nhập tên của bạn!!!")
        return
    history_faild = []
    history_record = 0
    while secret_number:
        try:
            number = int(input("Nhập số : "))
        except ValueError:
            print("Vui lòng nhập số!!!")
            continue

        history_record += 1
        if number < secret_number:
            print("Nhỏ hơn rồi")
            history_faild.append(number)
            continue
        elif number > secret_number:
            print("Lớn hơn rồi")
            history_faild.append(number)
            continue
        else:
            print("chúc mừng")
            is_reply = replay_action()
            if is_reply:
                tro_choi_doan_so()
            break
    
    save_data_to_file_txt(name,history_record)
    save_data_to_file_json(name,history_record)
    all_records[name] = history_record
    logger(all_records,name,history_faild,history_record)
    history_record = 0
    history_faild = []


read_data_to_file_txt()
read_data_to_file_json()
tro_choi_doan_so()


