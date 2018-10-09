exports.createIssueOnGithub = (functions, filer, comment, original) => {
  const octokit = require('@octokit/rest')()
  console.log( "auth: ", process.env.GITHUB_ACCESS_TOKEN )
  octokit.authenticate({
    type: "oauth",
    token: process.env.GITHUB_ACCESS_TOKEN || functions.config().github.token
  })

  const owner = "tedhyde"
  const repo = "btwg2.teddyhyde.io"
  const title = "Change request"
  const body = `

Filed by @${filer}

${comment}

Original quoted text:

${original.split( "\n" ).map( line => ">" + line ).join( "\n" ) }

`;
  console.log( "Params: ", filer, repo, title, body );
  return octokit.issues.create({owner, repo, title, body})
}
