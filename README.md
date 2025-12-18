# My Flutter App

A comprehensive Flutter application featuring maps, charts, and secure payment integrations. This project demonstrates a robust architecture using GetX for state management and various plugins for enhanced functionality.

## Features

*   **State Management**: efficient state management using [GetX](https://pub.dev/packages/get).
*   **Local Database**: Persistent storage with [sqflite](https://pub.dev/packages/sqflite).
*   **Maps & Location**: Integrated Google Maps and Geocoding.
*   **Payments**: Secure payment processing with Stripe and Razorpay.
*   **Charts**: Data visualization using Syncfusion Flutter Charts.
*   **UI Components**: Custom fonts (Metropolis), infinite scrolling, and image sliders.

## Getting Started

### Prerequisites

*   [Flutter SDK](https://flutter.dev/docs/get-started/install)
*   [Dart SDK](https://dart.dev/get-dart)
*   An IDE (VS Code or Android Studio)

### Installation

1.  **Clone the repository:**
    ```bash
    git clone <repository-url>
    cd my_flutter_app
    ```

2.  **Install dependencies:**
    ```bash
    flutter pub get
    ```

3.  **Setup Environment Variables:**
    *   Check `assets/.env` and ensure all required API keys (Stripe, Google Maps, etc.) are populated.

## Stripe Payment Gateway Setup

To successfully test and use the Stripe payment gateway, you need to run a backend server and expose it via ngrok. Follow these steps carefully:

### Step 1: Run the Server Project

1.  Navigate to your backend server project directory (this is a separate project typically in Node.js/Express).
2.  Install dependencies (if not already done):
    ```bash
    npm install
    ```
3.  Start the server:
    ```bash
    npm start
    ```
    *   *Note: Ensure your server is running on port 3000.*

### Step 2: Expose Server with Ngrok

To allow the Flutter app (running on a device/emulator) to communicate with your local server, use ngrok to create a secure tunnel.

1.  Open a new terminal window or tab.
2.  Run the following command:
    ```bash
    ngrok http 3000
    ```
3.  Copy the **Forwarding URL** typically looking like `https://<random-id>.ngrok-free.app`.

### Step 3: Configure the Flutter App

1.  Open your Flutter project.
2.  Locate your API configuration file (e.g., inside `lib/utils` or `assets/.env`).
3.  Update the `BASE_URL` or equivalent variable with the new ngrok URL you copied in the previous step.

### Step 4: Run the Flutter App

Once the server is running and tunneled, launch the application:

```bash
flutter run
```

Now you can navigate to the payment section and test the Stripe integration.

## Folder Structure

*   **/lib**: Main application source code.
*   **/assets**: Images, fonts, and environment files.
*   **/test**: Unit and widget tests.

## Contributing

Contributions are welcome! Please open an issue or submit a pull request.
