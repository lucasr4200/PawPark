# PawPark

PawPark is an iOS app I built for dog lovers to discover, rate, and share information about off‑leash dog parks in their city! Built with SwiftUI, it integrates:

* **Interactive Map**: View all parks in your city and tap pins for quick details.
* **List View**: Browse parks sorted by proximity or filter by city name.
* **Park Details**: See photos, availability of free water, off‑leash area size, user ratings (★1–5), and comments.
* **User Accounts**: Sign in with Apple, email/password, or continue as a guest. Authenticated users can rate and comment.
* **Favorites**: Mark parks you love for one‑tap access.
* **Profile & Settings**:

  * Customize your display name and background photo.
  * Manage your dog profiles (enter one or multiple dog names).
  * Sign out from your account.
* **Connections**: Scan QR codes to connect with fellow dog‑park friends. View your connections list by name and dog profiles.
* **Responsive UI**: A draggable bottom sheet on the Home screen shows quick actions and nearby parks, and expands for a detailed list.
* **Offline & Security**: Firestore rules restrict access—each user only reads/writes their own data.

---

## 🚀 Getting Started

### Prerequisites

* Xcode 15 or later
* iOS 16.0+ deployment target
* A Firebase project with Firestore & Authentication enabled

### 1. Clone the Repo

```bash
git clone https://github.com/your‑username/PawPark.git
cd PawPark
```

### 2. Install Dependencies

The project uses Swift Package Manager for Firebase and SPM‑based libraries. Xcode will resolve them automatically when you open `PawPark.xcodeproj`.

If you’re using CocoaPods instead, run:

```bash
pod install
open PawPark.xcworkspace
```

### 3. Add Firebase Configuration

1. Create your own Firebase iOS app in the Firebase Console.
2. Download the generated **GoogleService-Info.plist**.
3. Copy it into the Xcode project root (next to the `.xcodeproj`).
4. **Do not commit** this file—use the existing `GoogleService-Info.plist.example` as a template.

### 4. Configure Info.plist

* Add **Privacy - Camera Usage Description** (`NSCameraUsageDescription`) with a message (e.g., “We need camera access to scan QR codes for user connections.”).
* Add **Privacy - Photo Library Usage Description** if customizing background images.

### 5. Review Firestore Rules

Open your Firebase Console → Firestore → **Rules**, and replace with:

```js
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{uid} {
      allow read, write: if request.auth.uid == uid;
    }
    match /connections/{uid}/peers/{peerId} {
      allow read, write: if request.auth.uid == uid;
    }
    match /ratings/{ratingId} {
      allow create, read: if request.auth != null;
      allow update, delete: if false;
    }
    match /parks/{parkId} {
      allow read: if true;
    }
  }
}
```

### 6. Build & Run

* Open the project in Xcode: `open PawPark.xcodeproj` (or `.xcworkspace`).
* Select your target device/simulator.
* Hit **Run** (⌘R).

The app will prompt for location and camera permissions. Sign in or continue as a guest to explore!

---

## 📚 Folder Structure

```
PawPark/                   # root folder
├─ PawPark/               # Xcode SwiftUI app target
│  ├─ Assets.xcassets
│  ├─ AccountSettingsView.swift
│  ├─ AuthViewModel.swift
│  ├─ Connection.swift
│  ├─ ConnectionQRView.swift
│  ├─ ConnectionsListView.swift
│  ├─ ConnectionsRepository.swift
│  ├─ ContentView.swift
│  ├─ CustomizationView.swift
│  ├─ DogPark.swift
│  ├─ DogProfile.swift
│  ├─ DogProfilesView.swift
│  ├─ DogSetupView.swift
│  ├─ DogsRepository.swift
│  ├─ EmailAuthView.swift
│  ├─ FavoritesListView.swift
│  ├─ FavoritesRepository.swift
│  ├─ FirebaseManager.swift
│  ├─ FirestorePrepopulator.swift
│  ├─ FullScreenImageViewer.swift
│  ├─ GoogleService-Info.plist.example
│  ├─ HomeView.swift
│  ├─ Info.plist
│  ├─ LocationManager.swift
│  ├─ NonceHelper.swift
│  ├─ ParkDetailView.swift
│  ├─ ParkRepository.swift
│  ├─ ParksListView.swift
│  ├─ ParksMapView.swift
│  ├─ PawParkApp.swift
│  ├─ QRScannerView.swift
│  ├─ Rating.swift
│  ├─ RatingService.swift
│  ├─ SettingsView.swift
│  ├─ SettingsViewModel.swift
│  ├─ SignInView.swift
│  └─ Theme.swift
├─ PawPark.xcodeproj       # Xcode project
├─ PawParkTests/           # unit tests
├─ PawParkUITests/         # UI tests
├─ .gitignore
└─ README.md               # this doc
```

---

## 🤝 Contributing

1. Fork the repo
2. Create a feature branch (`git checkout -b feature/my-feature`)
3. Commit your changes (`git commit -am 'Add new feature'`)
4. Push to the branch (`git push origin feature/my-feature`)
5. Open a Pull Request against `main`

Please ensure your code follows SwiftLint rules.

---

## 📄 License

This project is open-source under the **MIT License**. See `LICENSE.md` for details.
