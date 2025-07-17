

import { initializeApp } from "firebase/app";
import { getFirestore } from "firebase/firestore"; 
import { getAuth } from "firebase/auth";           
import { getStorage } from "firebase/storage";   
const firebaseConfig = {
  apiKey: "AIzaSyDkXHVGIF22wv31C3Z5zUxd59qpywc_ItA",
  authDomain: "svareign-c8744.firebaseapp.com",
  databaseURL: "https://svareign-c8744-default-rtdb.firebaseio.com",
  projectId: "svareign-c8744",
  storageBucket: "svareign-c8744.firebasestorage.app",
  messagingSenderId: "412848064485",
  appId: "1:412848064485:web:ac7b853315acb3aff7110c"
};

const app = initializeApp(firebaseConfig);


const db = getFirestore(app);
const auth = getAuth(app);
const storage = getStorage(app); 


export { app, db, auth, storage };
