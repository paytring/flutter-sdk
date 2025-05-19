# Paytring Flutter SDK

A Flutter SDK to integrate **Paytring Checkout** using a web-based flow embedded inside your app using an `InAppWebView`.

---

## ✨ Features

* Simple integration to trigger Paytring checkout.
* Callback support for:

  * ✅ Payment success
  * ❌ Payment failure
  * 📢 General SDK events
* Secure checkout with order ID integration.
* WebView-based experience inside a dialog.

---

## 📦 Installation

Add the following dependency to your `pubspec.yaml`:

```yaml
dependencies:
  paytring:
    git:
    url: https://github.com/paytring/flutter-sdk # or use git/path accordingly
```

---

## 🚀 Usage

### 1. **Import the package**

Import the SDK in your Dart file:

```dart
import 'package:paytring/paytring.dart';
```

### 2. **Initialize the SDK**

Create an instance of the Paytring SDK:

```dart
final _paytringPlugin = Paytring();
```

### 3. **Trigger the Checkout Flow**

To start the payment process, you need a valid `orderId`. You also need to pass three functions that define what should happen when:

* the payment succeeds
* the payment fails
* an event occurs within the SDK

This makes it easy for you to customize behavior (e.g., show a success page, retry on failure, or log analytics).

```dart
String orderId = '765136280629320081'; // Replace with your actual order ID

if (orderId.isNotEmpty) {
  _paytringPlugin.open(
    context,
    orderId,
    () {
      print("✅ Payment Successful");
      // Add your success logic here (e.g., navigate to thank you page)
    },
    () {
      print("❌ Payment Failed");
      // Add failure handling logic (e.g., show retry option)
    },
    () {
      print("📢 SDK Event Triggered");
      // Use this for tracking or debugging
    },
  );
}
```

---

## 🔧 SDK Internals

When `open()` is called, the SDK performs the following operations:

* Configures platform-specific method channels.
* Initializes and stacks a WebView dialog to show the payment screen.
* Passes the necessary callbacks for success, failure, and general events.
* Displays the WebView dialog for user interaction.

Note: Internal implementation such as widget stacking and WebView setup is abstracted for the developer’s ease.

---

## 🔁 Callbacks

* `successCallback()` – Called when the payment is successful.
* `failureCallback()` – Called when the payment fails.
* `eventCallback()` – Called when a general event or pending from the SDK is triggered (for logging or analytics).

---


