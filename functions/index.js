const functions = require('firebase-functions');
const admin = require('firebase-admin');
const fetch = require( 'node-fetch' );
admin.initializeApp();
const createIssueOnGithub = require('./issue').createIssueOnGithub

require('dotenv').config()
// Since this code will be running in the Cloud Functions environment
// we call initialize Firestore without any arguments because it
// detects authentication from the environment.
const firestore = admin.firestore();
const util = require('util')
// Create a new function which is triggered on changes to /status/{uid}
// Note: This is a Realtime Database trigger, *not* Cloud Firestore.

exports.createNewIssue = functions.firestore.document( '{uid}/{document}' ).onCreate(
  (snapshot, context) => {
    //console.log( "Context",
    // util.inspect( snapshot ),
    //util.inspect( context ) );
    const uid = context.params.uid;
    console.log( "UID: ", uid );
    
    return admin.auth().getUser(uid)
      .then( user => {
	console.log( "User: ", user );
	return fetch( `https://api.github.com/user/${user.providerData[0].uid}` )
      })
      .then( res => {
	console.log( "Response: ", res );
	return res.json()
      })
      .then( user => {
	console.log( "User is: ", user )
	return user.login;
      })
      .then( owner => {
	console.log( "Owner is: ", owner );
	const data = snapshot.data();
	const comment = data.comment;
	const original = data.original;
	return createIssueOnGithub( functions, owner, comment, original )
      })
      .then( result => {
	// ... and write it to Firestore.
	const url = result.data.url;
	return snapshot.ref.set( { url: url }, { merge: true } );
      })
      .catch( error => {
	console.error( "Error: ", error );
      });
  }
);

