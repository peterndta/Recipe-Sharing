const config = {
    NODE_ENV: process.env.NODE_ENV || 'production',
    APP_API_URL: process.env.REACT_APP_API_URL,
    FIREBASE_apiKey: process.env.REACT_APP_FIREBASE_apiKey,
    FIREBASE_authDomain: process.env.REACT_APP_FIREBASE_authDomain,
    FIREBASE_projectId: process.env.REACT_APP_FIREBASE_projectId,
    FIREBASE_storageBucket: process.env.REACT_APP_FIREBASE_storageBucket,
    FIREBASE_messagingSenderId: process.env.REACT_APP_FIREBASE_messagingSenderId,
    FIREBASE_appId: process.env.REACT_APP_FIREBASE_appId,
    LOCALSTORAGE_TOKEN_NAME: 'token',
}

export const {
    NODE_ENV,
    APP_API_URL,
    FIREBASE_apiKey,
    FIREBASE_authDomain,
    FIREBASE_projectId,
    FIREBASE_storageBucket,
    FIREBASE_messagingSenderId,
    FIREBASE_appId,
    LOCALSTORAGE_TOKEN_NAME,
} = config
