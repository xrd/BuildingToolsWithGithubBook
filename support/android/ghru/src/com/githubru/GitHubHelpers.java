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

    GitHubHelper() {
    }

    private String getFilename( String post ) { // <1>
        String title = post.substring( 0, post.length() > 30 ? 30 : post.length() );
        String jekyllfied = title.toLowerCase().replaceAll( "\\W+", "-").replaceAll( "\\W+$", "" );
        SimpleDateFormat sdf = new SimpleDateFormat( "yyyy-MM-dd-" );
        String prefix = sdf.format( new Date() );
        String filename = "_posts/" + prefix + jekyllfied + ".md";
        return filename;
    }

    public RepositoryBranch getBranch( RepositoryService repositoryService ) {
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


    private String createBlob( String contentsBase64 ) {
	Random random = new Random();
	Blob blob = new Blob();
	blob.setContent(contentsBase64);
	blob.setEncoding(Blob.ENCODING_BASE64);
	return dataService.createBlob(repository, blob);
    }
    
    private TreeEntry generateTree() {
	TreeEntry treeEntry = new TreeEntry();
	treeEntry.setPath(filename);
	treeEntry.setMode(TreeEntry.MODE_BLOB);
	treeEntry.setType(TreeEntry.TYPE_BLOB);
	treeEntry.setSha(blobSha);
	treeEntry.setSize(blob.getContent().length());
	Collection<TreeEntry> entries = new ArrayList<TreeEntry>();
	entries.add(treeEntry);
	Tree newTree = dataService.createTree(repository, entries, baseTree.getSha());
	return newTree;
    }


    RepositoryService repositoryService;
    CommitService commitService;
    DataService dataService;
    private boolean createServices() {
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
    private String retrieveBaseSha() {
        // get some sha's from current state in git
        repository =  repositoryService.getRepository(login, repoName);
        theBranch = getBranch(); 
        return theBranch.getCommit().getSha();
    }

    private String createBlobFromSha() {
        // create new blob with data
        Tree baseTree = dataService.getTree(repository, baseCommitSha);
        return blobSha = createBlob();
    }

    Commit newCommit;
    private void createCommit() {
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

    private void updateMasterResource() {
        // get master reference and update it
        Reference reference = dataService.getReference(repository, "heads/" + theBranch.getName() );
        reference.setObject(commitResource);
        Reference response = dataService.editReference(repository, reference, true) ;
    }

    String blobSha;
    TreeEntry newTree;
    String commitMessage;
    String postContentsWithYfm;
    String contentsBase64;
    String filename;

    private void generateContent() {
        commitMessage = "GitHubRu Update";
        postContentsWithYfm = "---\nlayout: post\npublished: true\n---\n\n" + post; // <2>
        contentsBase64 = new String( Base64.encodeBase64( postContentsWithYfm.getBytes() ) );  // <3>
        filename = getFilename( post );
    }

    public static boolean SaveFile( String login, String password, String repoName,
                                    String post ) {
        
        boolean rv = false;

        try {
            generateContent();
            createServices();
            retrieveBaseSha();
            createBlobFromSha();
	    generateTree();
            createCommit();
            createResource();
            updateMasterResource();
            rv = true;
        }
        catch( IOException ieo ) {
            rv = false;
            ieo.printStackTrace();
        }

        return rv;
    }
}
