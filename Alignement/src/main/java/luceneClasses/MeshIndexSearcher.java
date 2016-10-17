package luceneClasses;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import java.io.IOException;
import java.nio.charset.Charset;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.List;

import org.apache.lucene.analysis.Analyzer;
import org.apache.lucene.analysis.core.SimpleAnalyzer;
import org.apache.lucene.document.Document;
import org.apache.lucene.index.DirectoryReader;
import org.apache.lucene.index.IndexReader;
import org.apache.lucene.index.Term;
import org.apache.lucene.queryparser.classic.ParseException;
import org.apache.lucene.queryparser.classic.QueryParser;
import org.apache.lucene.search.BooleanQuery;
import org.apache.lucene.search.FuzzyQuery;
import org.apache.lucene.search.IndexSearcher;
import org.apache.lucene.search.Query;
import org.apache.lucene.search.ScoreDoc;
import org.apache.lucene.search.TermQuery;
import org.apache.lucene.search.BooleanClause.Occur;
import org.apache.lucene.store.Directory;
import org.apache.lucene.store.FSDirectory;
import org.apache.lucene.util.Version;

public class MeshIndexSearcher {

	private Analyzer analyzer = new SimpleAnalyzer(Version.LUCENE_40);;
	private Directory directory = null;
    private IndexReader ireader = null;
    private IndexSearcher isearcher = null;
	private String dossier_index=  null;
	
	public String get_dossier_index(){
		return dossier_index;
	}
	
    public MeshIndexSearcher(String dossier_index) throws IOException{
    	this.dossier_index = dossier_index;
    	directory = FSDirectory.open(new File(dossier_index));
    	ireader = DirectoryReader.open(directory);
    	isearcher = new IndexSearcher(ireader);
    }
    
    
    
    public String search_fuzzy (String terme, String champs, int max_hit, int distance) throws IOException{
	    String newRequest_normalizer = MonNormaliser.normalise(terme);
	    QueryParser parser = new QueryParser(Version.LUCENE_40, champs, analyzer);
	    //System.out.println("Requete normalisée : " + newRequest_normalizer);
	    Query query = null;
		query = new FuzzyQuery(new Term(champs,newRequest_normalizer), distance);
	    
		ScoreDoc[] hits = isearcher.search(query, null, 10).scoreDocs;
		 if (hits.length == 0) {
	           //System.out.println("No matches were found for \"" + terme + "\"");
	           //return ("0\t0\t0\t");
	           return (terme + "\t" + "pas trouvé");
	        }
	     else {
	       //for (int i = 0; i < hits.length; i++) {
	      
	    int max_resultat = hits.length < max_hit ? hits.length : max_hit ;
	    String concatenation_resultat = "";
	    for (int i = 0; i < max_resultat; i++) {
	       Document doc = isearcher.doc(hits[i].doc);float score=hits[i].score;
	       String concept=doc.get("libelle");
	       String code  = doc.get("code");
	       concatenation_resultat = concatenation_resultat.concat(terme + "\t" + score + "\t" + concept + "\t" + code + "\n");
	    }
	    
	    return (concatenation_resultat);
	     }
		 
    }
    
    public String search_fuzzy (String terme, String champs, int max_hit, int distance, String terminologie) throws IOException{
    	System.out.println("search_fuzzy" + terme); 
    	String newRequest_normalizer = MonNormaliser.normalise(terme);
	    QueryParser parser = new QueryParser(Version.LUCENE_40, champs, analyzer);
	    //System.out.println("Requete normalisée : " + newRequest_normalizer);
	    Query query = null;
		query = new FuzzyQuery(new Term(champs,newRequest_normalizer), distance);
	    
		Query chercher_termino = new TermQuery(new Term("termino",terminologie));
		BooleanQuery booleanQuery = new BooleanQuery();
		booleanQuery.add(query, Occur.MUST);
		booleanQuery.add(chercher_termino, Occur.MUST);
		
		
		ScoreDoc[] hits = isearcher.search(booleanQuery, null, 10).scoreDocs;
		 if (hits.length == 0) {
	           //System.out.println("No matches were found for \"" + terme + "\"");
	           //return ("0\t0\t0\t");
	           return (terme + "\t" + "pas trouvé");
	        }
	     else {
	       //for (int i = 0; i < hits.length; i++) {
	      
	    int max_resultat = hits.length < max_hit ? hits.length : max_hit ;
	    String concatenation_resultat = "";
	    for (int i = 0; i < max_resultat; i++) {
	       Document doc = isearcher.doc(hits[i].doc);float score=hits[i].score;
	       String concept=doc.get("libelle");
	       String code  = doc.get("code");
	       concatenation_resultat = concatenation_resultat.concat(terme + "\t" + score + "\t" + concept + "\t" + code + "\n");
	    }
	    
	    return (concatenation_resultat);
	     }
		 
    }
    
    public float get_max_score (String terme, String champs) throws IOException{
    	String newRequest_normalizer = MonNormaliser.normalise(terme);
	    QueryParser parser = new QueryParser(Version.LUCENE_40, champs, analyzer);
	    Query query = null;
		try {
			query = parser.parse(newRequest_normalizer);
		} catch (ParseException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}//query.setBoost(0);
	    
		ScoreDoc[] hits = isearcher.search(query, null, 100).scoreDocs;
		 if (hits.length == 0) {
	           return (0);
	        }
	     else {
	      float score=hits[0].score;
	      return score;
	      }
    }
    
    public String search_term_sniiram (String termeinitial,String terme, String champs, int max_hit) throws IOException{
    	System.out.println("search_term" + terme); 
    	//String newRequest_normalizer = meshNormalizer.normalizeContent(terme);
    	String newRequest_normalizer = terme ; 
	    QueryParser parser = new QueryParser(Version.LUCENE_40, champs, analyzer);
	    //System.out.println("Requete normalisée : " + newRequest_normalizer);
	    Query query = null;
		try {
			query = parser.parse(newRequest_normalizer);
		} catch (ParseException e) {
			// TODO Auto-generated catch block
			//e.printStackTrace();
			return (terme + "\t" + "Exception");
		}//query.setBoost(0);
	    
		ScoreDoc[] hits = isearcher.search(query, null, 100).scoreDocs;
		 if (hits.length == 0) {
	           //System.out.println("No matches were found for \"" + terme + "\"");
	           //return ("0\t0\t0\t");
	           return (terme + "\t" + "pas trouvé");
	        }
	     else {
	       //for (int i = 0; i < hits.length; i++) {
	      
	    int max_resultat = hits.length < max_hit ? hits.length : max_hit ;
	    String concatenation_resultat = "";
	    for (int i = 0; i < max_resultat; i++) {
	       Document doc = isearcher.doc(hits[i].doc);float score=hits[i].score;
	       String concept=doc.get("libelle");
	       //String termino = doc.get("termino");
	       String code  = doc.get("code");
	       concatenation_resultat = concatenation_resultat.concat(termeinitial + "\t" + score + "\t" + concept + "\t" + code);
	       if (max_hit != 1){
	    	   concatenation_resultat = concatenation_resultat.concat("\n");
	       }
	    }
	    
	    return (concatenation_resultat);
	     }
		 
    }
    
    public String search_term (String terme, String champs, int max_hit) throws IOException{
    	System.out.println("search_term" + terme); 
    	//String newRequest_normalizer = meshNormalizer.normalizeContent(terme);
    	String newRequest_normalizer = terme ; 
	    QueryParser parser = new QueryParser(Version.LUCENE_40, champs, analyzer);
	    //System.out.println("Requete normalisée : " + newRequest_normalizer);
	    Query query = null;
		try {
			query = parser.parse(newRequest_normalizer);
		} catch (ParseException e) {
			// TODO Auto-generated catch block
			//e.printStackTrace();
			return (terme + "\t" + "Exception");
		}//query.setBoost(0);
	    
		ScoreDoc[] hits = isearcher.search(query, null, 100).scoreDocs;
		 if (hits.length == 0) {
	           //System.out.println("No matches were found for \"" + terme + "\"");
	           //return ("0\t0\t0\t");
	           return (terme + "\t" + "pas trouvé");
	        }
	     else {
	       //for (int i = 0; i < hits.length; i++) {
	      
	    int max_resultat = hits.length < max_hit ? hits.length : max_hit ;
	    String concatenation_resultat = "";
	    for (int i = 0; i < max_resultat; i++) {
	       Document doc = isearcher.doc(hits[i].doc);float score=hits[i].score;
	       String concept=doc.get("libelle");
	       //String termino = doc.get("termino");
	       String code  = doc.get("code");
	       concatenation_resultat = concatenation_resultat.concat(terme + "\t" + score + "\t" + concept + "\t" + code);
	       if (max_hit != 1){
	    	   concatenation_resultat = concatenation_resultat.concat("\n");
	       }
	    }
	    
	    return (concatenation_resultat);
	     }
		 
    }
    
    // possibilité de rechercher dans une termino
    public String search_term (String terme, String champs, int max_hit, String terminologie) throws IOException{
    	System.out.println("search_term" + terme); 
    	//String newRequest_normalizer = meshNormalizer.normalizeContent(terme);
    	String newRequest_normalizer = terme ; 
    	//String newRequest_normalizer = meshNormalizer.normalizeContent(terme);
	    QueryParser parser = new QueryParser(Version.LUCENE_40, champs, analyzer);
	    //System.out.println("Requete normalisée : " + newRequest_normalizer);
	    Query query = null;
		try {
			query = parser.parse(newRequest_normalizer);
		} catch (ParseException e) {
			// TODO Auto-generated catch block
			//e.printStackTrace();
		}//query.setBoost(0);
	    
		Query chercher_termino = new TermQuery(new Term("termino",terminologie));
		
		
		BooleanQuery booleanQuery = new BooleanQuery();
		booleanQuery.add(query, Occur.MUST);
		booleanQuery.add(chercher_termino, Occur.MUST);
		
		ScoreDoc[] hits = isearcher.search(booleanQuery, null, 100).scoreDocs;
		 if (hits.length == 0) {
	           //System.out.println("No matches were found for \"" + terme + "\"");
	           //return ("0\t0\t0\t");
	           return (terme + "\t" + "pas trouvé");
	        }
	     else {
	       //for (int i = 0; i < hits.length; i++) {
	      
	    int max_resultat = hits.length < max_hit ? hits.length : max_hit ;
	    String concatenation_resultat = "";
	    for (int i = 0; i < max_resultat; i++) {
	       Document doc = isearcher.doc(hits[i].doc);float score=hits[i].score;
	       String concept=doc.get("libelle");
	       //String termino = doc.get("termino");
	       String code  = doc.get("code");
	       concatenation_resultat = concatenation_resultat.concat(terme + "\t" + score + "\t" + concept + "\t" + code);
	       if (max_hit != 1){
	    	   concatenation_resultat = concatenation_resultat.concat("\n");
	       }
	    }
	    
	    return (concatenation_resultat);
	     }
		 
    }
    
    public String search_exact_term (String terme, String champs, int max_hit, String terminologie) throws IOException{
    	System.out.println("search_exact_term" + terme); 
    	Query query = new TermQuery(new Term(champs,terme));	    
		Query chercher_termino = new TermQuery(new Term("termino",terminologie));
		BooleanQuery booleanQuery = new BooleanQuery();
		booleanQuery.add(query, Occur.MUST);
		booleanQuery.add(chercher_termino, Occur.MUST);
		
		ScoreDoc[] hits = isearcher.search(booleanQuery, null, 100).scoreDocs;
		 if (hits.length == 0) {
	           //System.out.println("No matches were found for \"" + terme + "\"");
	           //return ("0\t0\t0\t");
	           return (terme + "\t" + "pas trouvé");
	        }
	     else {
	       //for (int i = 0; i < hits.length; i++) {
	      
	    int max_resultat = hits.length < max_hit ? hits.length : max_hit ;
	    String concatenation_resultat = "";
	    for (int i = 0; i < max_resultat; i++) {
	       Document doc = isearcher.doc(hits[i].doc);float score=hits[i].score;
	       String concept=doc.get("libelle");
	       String code  = doc.get("code");
	       concatenation_resultat = concatenation_resultat.concat(terme + "\t" + score + "\t" + concept + "\t" + code);
	       if (max_hit != 1){
	    	   concatenation_resultat = concatenation_resultat.concat("\n");
	       }
	    }
	    
	    return (concatenation_resultat);
	     }
		 
    }
    
    public String search_exact_term (String terme, String champs, int max_hit) throws IOException{
    	System.out.println("search_exact_term" + terme);
    	Query query = new TermQuery(new Term(champs,terme));	
	    
		ScoreDoc[] hits = isearcher.search(query, null, 100).scoreDocs;
		 if (hits.length == 0) {
	           //System.out.println("No matches were found for \"" + terme + "\"");
	           //return ("0\t0\t0\t");
	           return (terme + "\t" + "pas trouvé");
	        }
	     else {
	       //for (int i = 0; i < hits.length; i++) {
	      
	    int max_resultat = hits.length < max_hit ? hits.length : max_hit ;
	    String concatenation_resultat = "";
	    for (int i = 0; i < max_resultat; i++) {
	       Document doc = isearcher.doc(hits[i].doc);float score=hits[i].score;
	       String concept=doc.get("libelle");
	       //sString termino = doc.get("termino");
	       String code  = doc.get("code");
	       concatenation_resultat = concatenation_resultat.concat(terme + "\t" + score + "\t" + concept + "\t" + code);
	       if (max_hit != 1){
	    	   concatenation_resultat = concatenation_resultat.concat("\n");
	       }
	    }
	    
	    return (concatenation_resultat);
	     }
		 
    }
 
}
