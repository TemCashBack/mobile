importScripts(
  'https://www.gstatic.com/firebasejs/10.13.2/firebase-app-compat.js'
);
importScripts(
  'https://www.gstatic.com/firebasejs/10.13.2/firebase-messaging-compat.js'
);

firebase.initializeApp({
  apiKey: 'AIzaSyBAUhPkB1OLsgDEh7857KPheJ3r5FxmN6I',
  authDomain: 'temcashback-914bc.firebaseapp.com',
  projectId: 'temcashback-914bc',
  storageBucket: 'temcashback-914bc.firebasestorage.app',
  messagingSenderId: '941351203236',
  appId: '1:941351203236:web:77e84c5009a095dc9e5131',
  measurementId: 'G-L29TEDX8QD',
});

const messaging = firebase.messaging();

messaging.onBackgroundMessage(function (payload) {
  console.log('[firebase-messaging-sw.js] Mensagem em background:', payload);
});
