// Initialize Firebase
// TODO: Replace with your project's customized code snippet
var user = undefined;
var original = undefined;

var config = {
    apiKey: "AIzaSyAN9gGLqhY_sgbUMoaTk4zqSJGb7_hm1fE",
    authDomain: "btwg2-c9c3f.firebaseapp.com",
    databaseURL: "https://btwg2-c9c3f.firebaseio.com",
    projectId: "btwg2-c9c3f",
};
firebase.initializeApp(config);
firebase.auth().onAuthStateChanged(function(_user) {
  if (_user) {
    console.log( "User is logged in, reusing" );
    user = _user;
  }
});

// Initialize Cloud Firestore through Firebase
var db = firebase.firestore();

// Disable deprecated features
db.settings({
    timestampsInSnapshots: true
});

const handleClick = (event) => {
  const el = event.target;
  console.log( "Clicked on", el.textContent );
  document.getElementById("selectedText").innerHTML = original = el.textContent;
  MicroModal.show('modal-1'); 
}

function cleanupEditing() {
  const els = getAllDottableElements();
  for( const index in els ) {
    const el = els[index];
    if( el ) {
      if( el.classList ) {
	el.classList.remove("dotted");
      }
      if( el.removeEventListener ) {
	el.removeEventListener('click', handleClick );
      }
    }
  };
}

function getUrlWhenReady(id) {
  db.collection(user.uid).doc(id)
    .onSnapshot(function(doc) {
      console.log("Current data: ", doc.data());
      const url = doc.data().url;
      if( url ) {
	console.log( "Finally got the URL: ", url );
	// Fix it
	const fixed = url.replace( 'api.github.com/repos', 'github.com' );
	const issueUrlEl = document.getElementById("issueUrl");
	issueUrlEl.innerHTML = `<a target="_new" href="${fixed}">Click here to visit it on GitHub</a>`;
	const issueDiv = document.getElementById("filedIssue");
	issueDiv.style.display = "block";
	setTimeout( () => { issueDiv.style.display = "none"; }, 8000 );
      }
    });
}

function addSomeData(data) {
  console.log( "Sending data with: ", user.uid, data );
  db.collection(user.uid).add({ comment: data, original })
    .then(function(docRef) {
      cleanupEditing();
      getUrlWhenReady(docRef.id);
      // Show the response.
    })
    .catch(function(error) {
      cleanupEditing();
      console.error("Error adding document: ", error);
    });
}

function loginToGithub() {
    var provider = new firebase.auth.GithubAuthProvider();

    firebase.auth().signInWithPopup(provider).then(function(result) {
	// This gives you a GitHub Access Token. You can use it to access the GitHub API.
	var token = result.credential.accessToken;
	// The signed-in user info.
	user = result.user;
	// ...
	console.log( "User: ", user );
	loggedIn();
    }).catch(function(error) {
	// Handle Errors here.
	var errorCode = error.code;
	var errorMessage = error.message;
	// The email of the user's account used.
	var email = error.email;
	// The firebase.auth.AuthCredential type that was used.
	var credential = error.credential;
	// ...
    });
}

function openIt() {
    MicroModal.show('modal-1'); 

}

function openCustomization() {
    MicroModal.show('modal-2'); 
}

function storeIt() {
    MicroModal.close('modal-1');

    var els = document.getElementsByTagName('input');
    let data = undefined;
    for( var index in els ) {
      if( els[index].name == "change" ) {
	    console.log( "Data is: ", els[index].value );
	    data = els[index].value;
	}
    }

    if( data ) {
	addSomeData( data );
    }
}

let editing = false;
function toggleEditing() {
  if( editing ) {
    toggleLoginInformation(false);
    toggleEditingInformation(false);
    cleanupEditing();
  }
  else {
    if( !user ) {
      let els = document.getElementsByClassName("fab-user");
      els[0].style.display = "inline";
      els = document.getElementsByClassName("login");
      els[0].style.display = "inline";
    }
    else {
      turnOffLoginAndEnableEditing();
    }
  }
  editing = !editing;
}

function toggleLoginInformation(onOff) {
  let login = document.getElementsByClassName("loginWrapper");
  login[0].style.display = onOff ? "inline" : "none";
}

function toggleEditingInformation(onOff) {
  let info = document.getElementsByClassName("informationalWrapper");
  info[0].style.display = onOff ? "inline" : "none";
  
  if( onOff ) {
    // Turn it off in 8 seconds...
    setTimeout( () => {
      info[0].style.display = "none";
    }, 8000 )
  }
}

function getAllDottableElements() {
  const els = document.getElementsByClassName("paragraph");
  let all = [].slice.call(els);
  const contents = document.getElementsByClassName("content");
  all = all.concat([].slice.call(contents));
  const lis = document.getElementsByTagName("li");
  all = all.concat([].slice.call(lis));
  return all;
}

function turnOffLoginAndEnableEditing() {
  toggleLoginInformation(false);
  toggleEditingInformation(true);
  
  const els = getAllDottableElements();
  for( const index in els ) {
      const el = els[index];
      if( el ) {
	if ( el.classList ) {
	  el.classList.add("dotted");
	}
	if( el.addEventListener ) {
	  el.addEventListener('click', handleClick );
	}
      }
    };
}
  
window.onload = function() {
  // Hide the body, and create a new excerpt
  const ps = document.getElementsByClassName( "paragraph" );
  const h2s = document.getElementsByTagName( "h2" );
  // Use the first one.

  const title = document.createElement("h2");
  title.innerHTML = h2s[0].innerHTML;

  var text = document.createElement("div");
  text.classList.add("paragraph");
  text.innerHTML = ps[0].innerHTML;

  const sectionbody = document.createElement("div");
  sectionbody.classList.add("sectionbody");
  sectionbody.appendChild(text);
  
  const wrapper = document.createElement("div");
  wrapper.classList.add("sect1");
  wrapper.id = "excerpt";
  wrapper.appendChild(title);
  wrapper.appendChild(sectionbody);
  
  document.body.insertBefore(wrapper, document.body.firstChild);
  
  const content = document.getElementById( "content" );
  content.style.display = "none";
}

TeddyHydeClient.onContribution( function() {
  revealContent();
});

function showAltMessage() {
  console.log( "Popping popup" );
  $('#personal_ad_popup').popup(
    {
      color: 'white',
      opacity: 1,
      transition: '0.3s',
      scrolllock: true
    }
  ).popup('show');
  
  setTimeout( function()  {
    console.log( "Hiding popup" );
    $('#personal_ad_popup').popup('hide');
    setTimeout( revealContent, 1000 );
  }, 15*1000 );
  
  // setDisplayById( "myad", "inline-block" );
  // setDisplayById("th", "none" );
  // setTimeout( function() {
  // 	revealContent();
  // 	setDisplayById( "myad", "none" );
  // }, 10*1000 );
  // console.log( "Hmm, you won't contribute, OK" );
}

TeddyHydeClient.onDecline( function() {
  showAltMessage();
  console.log( "Hey, we declined to pay!!!" );
});

TeddyHydeClient.onAlreadyPaid( function() {
  revealContent();
});


function setDisplayById( id, display ) {
  const el = document.getElementById(id);
  if (el) { el.style.display = display; }
}

function revealContent(){
  setDisplayById("excerpt", "none" );
  setDisplayById("content", "inline-block" );
}

