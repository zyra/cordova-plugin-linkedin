# Cordova LinkedIn Plugin
A Cordova plugin that lets you use LinkedIn Native SDKs for Android and iOS.

## Installation
1. Create a LinkedIn app [here](https://www.linkedin.com/developer/apps)
2. Click on your app's name, then select the **Mobile** page from the side menu
3. Add package name and hash for Android
4. Copy the **Application Id** in the iOS section and use it in the installation command below

```
cordova plugin add cordova-plugin-linkedin --variable APP_ID=YOUR_APP_ID
```

## Usage

### login
```js
login(scopes, promptToInstall, success, error)
```
* **scopes**: Scopes to authenticate with
* **promptToInstall**: If set to true, the user will be prompted to install the LinkedIn app if it's not already installed
Logs the user in with selected scopes. Available scopes are: `r_basicprofile`, `r_emailaddress`, `rw_company_admin` and `w_share`.

### logout
```js
logout()
```
A synchronous method that clears the existing session.

### getRequest
```js
getRequest(path, success, error)
```
* **path**: The request path
Makes a GET request to LinkedIn REST API. You can view the possible paths [here](https://developer.linkedin.com/docs).

### postRequest
```js
postRequest(path, body, success, error)
```
* **path**: The request path
* **body**: The reqeust body
Makes a POST request to LinkedIn REST API. You can view the possible paths [here](https://developer.linkedin.com/docs).

### openProfile
```js
openProfile(memberId, success, error)
```
* **memberId**: Member Id of the user
Opens a member's profile in the LinkedIn app.

### hasActiveSession
```js
hasActiveSession(success, error)
```
Checks if there is already an existing active session. This should be used to avoid unecessary login.

The success callback function will be called with one argument as a boolean, indicating whether there is an active session.


## Example
```js
// generic callback functions to make this example simpler
var onError = function(e) { console.error('LinkedIn Error: ', e); }
var onSuccesss = function(r) { console.log('LinkedIn Response: ', r); }

// logging in with all scopes
// you should just ask for what you need
var scopes = ['r_basicprofile', 'r_emailaddress', 'rw_company_admin', 'w_share'];

// login before doing anything
// this is needed, unless if we just logged in recently
cordova.plugins.LinkedIn.login(scopes, true, function() {

  // get connections
  cordova.plugins.LinkedIn.getRequest('people/~', onSuccess, onError);
  
  // share something on profile
  // see more info at https://developer.linkedin.com/docs/share-on-linkedin
  var payload = {
    comment: 'Hello world!',
    visibility: {
      code: 'anyone'
    }
  };
  cordova.plugins.LinkedIn.postRequest('~/shares', payload, onSuccess, onError);

}, onError);


// check for existing session
cordova.plugin.LinkedIn.hasActiveSession(function(exists) {
  if (exists) {
    console.log('We have an active session');
  } else {
    console.log('There is no active session, we need to call the login method');
  }
});

```
