const createIssueOnGithub = require('./issue').createIssueOnGithub;

createIssueOnGithub( "sadasd", "asdasdad" )
  .then( result => {
    return console.log( "Result: ", result );
  })
  .catch( error => {
    return console.error( "An error! ", error )
  });
