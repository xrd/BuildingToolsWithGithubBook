package com.githubru;

import org.eclipse.egit.github.core.*;
import org.eclipse.egit.github.core.service.CommitService;
import org.eclipse.egit.github.core.service.DataService;
import org.eclipse.egit.github.core.service.GistService;
import org.eclipse.egit.github.core.service.RepositoryService;
import org.apache.commons.codec.binary.Base64;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.io.IOException;
import java.util.*;

class GitHubHelper {

    String login;
    String password;

    GitHubHelper( String _login, String _password ) {
        login = _login;
        password = _password;
    }

    public boolean SaveFile( String _repoName, String _post ) {
        post = _post;
        repoName = _repoName;

        boolean rv = false;

        try {
            generateContent();
            createServices();
            retrieveBaseSha();
            createBlob();
	    generateTree();
            createCommit();
            createResource();
            updateMasterResource();
            rv = true;
        }
        catch( IOException ieo ) {
            ieo.printStackTrace();
        }

        return rv;
    }


    String blobSha;
    Tree newTree;
    String commitMessage;
    String postContentsWithYfm;
    String contentsBase64;
    String filename;
    String post;
    String repoName;

    private void generateContent() {
        commitMessage = "GitHubRu Update";
        postContentsWithYfm = "---\nlayout: post\npublished: true\n---\n\n" + post; 
        contentsBase64 = new String( Base64.encodeBase64( postContentsWithYfm.getBytes() ) ); 
        getFilename( post );
    }

    private void getFilename( String post ) { 
        String title = post.substring( 0, post.length() > 30 ? 30 : post.length() );
        String jekyllfied = title.toLowerCase().replaceAll( "\\W+", "-").replaceAll( "\\W+$", "" );
        SimpleDateFormat sdf = new SimpleDateFormat( "yyyy-MM-dd-" );
        String prefix = sdf.format( new Date() );
        filename = "_posts/" + prefix + jekyllfied + ".md";
    }

    Blob blob;
    private void createBlob() throws IOException {
	Random random = new Random();
	blob = new Blob();
	blob.setContent(contentsBase64);
	blob.setEncoding(Blob.ENCODING_BASE64);
	dataService.createBlob(repository, blob);
    }

    Tree baseTree;
    private void generateTree() throws IOException {
        baseTree = dataService.getTree(repository, baseCommitSha);
	TreeEntry treeEntry = new TreeEntry();
	treeEntry.setPath( filename );
	treeEntry.setMode( TreeEntry.MODE_BLOB );
	treeEntry.setType( TreeEntry.TYPE_BLOB );
	treeEntry.setSha(blobSha);
	treeEntry.setSize(blob.getContent().length());
	Collection<TreeEntry> entries = new ArrayList<TreeEntry>();
	entries.add(treeEntry);
	newTree = dataService.createTree( repository, entries, baseTree.getSha() );
    }

    RepositoryService repositoryService;
    CommitService commitService;
    DataService dataService;

    private void createServices() throws IOException {
        repositoryService = new RepositoryService();
        repositoryService.getClient().setCredentials( login, password );
        commitService = new CommitService();
        commitService.getClient().setCredentials( login, password );
        dataService = new DataService();
        dataService.getClient().setCredentials( login, password );
    }

    Repository repository;
    RepositoryBranch theBranch;
    String baseCommitSha;
    private String retrieveBaseSha() throws IOException {
        // get some sha's from current state in git
        repository =  repositoryService.getRepository(login, repoName);
        theBranch = getBranch(); 
        return theBranch.getCommit().getSha();
    }

    public RepositoryBranch getBranch() throws IOException {
	List<RepositoryBranch> branches = repositoryService.getBranches(repository);
	RepositoryBranch master = null;
	// Iterate over the branches and find gh-pages or master
	for( RepositoryBranch i : branches ) {
	    String theName = i.getName().toString();
	    if( theName.equalsIgnoreCase("gh-pages") ) {
		theBranch = i;
	    }
	    else if( theName.equalsIgnoreCase("master") ) {
		master = i;
	    }
	}
	if( null == theBranch ) {
	    theBranch = master;
	}
	return theBranch;
    }


    Commit newCommit;
    private void createCommit() throws IOException {
        // create commit
        Commit commit = new Commit();
        commit.setMessage( commitMessage );
        commit.setTree( newTree );
        List<Commit> listOfCommits = new ArrayList<Commit>();
        listOfCommits.add(new Commit().setSha(baseCommitSha));
        commit.setParents(listOfCommits);
        newCommit = dataService.createCommit(repository, commit);
    }

    TypedResource commitResource;
    private void createResource() {
        commitResource = new TypedResource();            
        commitResource.setSha(newCommit.getSha());
        commitResource.setType(TypedResource.TYPE_COMMIT);
        commitResource.setUrl(newCommit.getUrl());
    }

    private void updateMasterResource() throws IOException {
        // get master reference and update it
        Reference reference = dataService.getReference(repository, "heads/" + theBranch.getName() );
        reference.setObject(commitResource);
        Reference response = dataService.editReference(repository, reference, true) ;
    }


}
