// Firebase web service worker for background push notifications.
// ⚠️  Replace the config values below with your Firebase project's web config
//     (available in Firebase Console → Project Settings → Your apps → Web app).
// After running `flutterfire configure`, copy the web config values here.

importScripts("https://www.gstatic.com/firebasejs/10.7.1/firebase-app-compat.js");
importScripts("https://www.gstatic.com/firebasejs/10.7.1/firebase-messaging-compat.js");

firebase.initializeApp({
  apiKey: "AIzaSyALQyO2Gun6I1JAH9nRmglMVRFrndaNb9w",
  authDomain: "namaa-driver-dba2f.firebaseapp.com",
  projectId: "namaa-driver-dba2f",
  storageBucket: "namaa-driver-dba2f.firebasestorage.app",
  messagingSenderId: "739032693246",
  appId: "1:739032693246:web:8e1db1b530baf4ed9768af",
  measurementId: "G-X3C4GNKMVE",
});

const messaging = firebase.messaging();

// Handle background messages
messaging.onBackgroundMessage((payload) => {
  const { title, body } = payload.notification ?? {};
  return self.registration.showNotification(title ?? "Namaa Driver", {
    body: body ?? "",
    icon: "/icons/Icon-192.png",
    badge: "/icons/Icon-192.png",
    data: payload.data,
    tag: payload.data?.type ?? "general",
  });
});
