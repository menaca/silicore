![Logo Here (2)](https://github.com/user-attachments/assets/0172a9d5-2b5a-4752-bd7c-d87280d2757f)

# 📱Silicore 
***Turn any PC into a remotely controlled smart device.***

Ever wanted to check your PC's status, take screenshots or shutdown remotely?
Silicore Client turns your Windows computer into a secure, silent and remotely controllable system using only Firebase.

## 🖥️ Silicore Client (Required)

This app requires a companion **Python client** to be running on the target computer. It collects system data and listens for Firebase commands.

> 📦 The Python client is available: [Silicore Client](https://github.com/menaca/silicore_client)


### Key Features 📝:

1. **Real-time Monitoring** 📊:
   - Monitor CPU, RAM, Battery, and Disk usage on your computer.
   - View detailed information like OS version, CPU brand, and screen resolution.
   - Real-time status updates for online/offline status.
  
2. **Remote Control** 🖥️:
   - Take a screenshot remotely 📸
   - Shutdown the computer remotely 🔴
   - View and manage processes running on the computer in real-time.
   
3. **Task List** 🧑‍💻:
   - View all running tasks with details like CPU and memory usage.
   - Sort tasks based on CPU or memory usage.
   - Filter and search for specific processes.
   - Terminate selected processes remotely.

4. **Battery** 🔋:
   - Get instant updates on battery status and charge percentage.
   - Check whether the device is plugged in or running on battery.

5. **Multi-language** 🌍:
   - The app supports **English** and **Turkish**.

### How to Use 📲:

1. **Install Flutter**:
   - Make sure you have Flutter installed on your system. [Flutter Installation Guide](https://flutter.dev/docs/get-started/install).

2. **Clone the Repository**:
   ```bash
   git clone https://github.com/menaca/silicore.git
   cd silicore
   ```
   
3. **Install Dependencies: Run the following command to get all necessary dependencies:**

    ```bash
    flutter pub get
    ```
4. **Firebase Setup:**

   ***Set up Firebase for your project by following the FlutterFire setup guide.***

   This project is integrated with Firebase. Files like `firebase_options.dart`, `google-services.json` and `firebase.json` are included in `.gitignore` *For setup:*

   ```bash
   flutterfire configure
   ```

5. **Run the App:**

    ```bash
    flutter run
    ```
### Screenshots 📸:

## 🖥️ Silicore Client

The Python-based Silicore Client allows you to:

- 🔑 Shows code to pair with your phone
- 📊 Sends real-time system data to database
- 📸 Takes and sends screenshots whenever you want
- 🧠 Sends a list of running processes whenever you want and kills them
- 🔌 Remotely shuts down your computer

👉 [Check out the Silicore Client Repository](https://github.com/menaca/silicore_client)

> Do you want to control your computer from your phone and get instant information? Silicore is for you

Check out all my projects [menapps](https://www.instagram.com/menapps).

![Logo Here (1)](https://github.com/user-attachments/assets/550db88f-7cee-4339-8858-811d3654cf13)
