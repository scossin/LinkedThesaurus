package luceneClasses;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.IOException;
import org.apache.lucene.analysis.Analyzer;
import org.apache.lucene.analysis.TokenStream;
import org.apache.lucene.analysis.core.SimpleAnalyzer;
import org.apache.lucene.document.Document;
import org.apache.lucene.document.Field;
import org.apache.lucene.document.StringField;
import org.apache.lucene.index.IndexWriter;
import org.apache.lucene.index.IndexWriterConfig;
import org.apache.lucene.index.IndexWriterConfig.OpenMode;
import org.apache.lucene.store.Directory;
import org.apache.lucene.store.FSDirectory;
import org.apache.lucene.util.Version;

public class MeshCSVIndexer {
	String fichier_a_indexer = null;
	String dossier_index=  null;
	Analyzer analyzer = new SimpleAnalyzer(Version.LUCENE_47);
	String[] champs= null;
	char[] actions = null;
	String separateur = null;
	OpenMode openMode = null;
	
	public MeshCSVIndexer(String fichier_a_indexer, String dossier_index, String[]  champs, String separateur,
			char[] actions, OpenMode openMode){
		this.fichier_a_indexer = fichier_a_indexer;
		this.dossier_index = dossier_index;
		this.champs = champs;
		this.separateur = separateur;
		this.actions = actions;
		if (actions.length != champs.length){
			System.out.println("Erreur : longueur de champs différent de longueur action");
		}
		this.openMode = openMode;
	}
	
	public void index_File() throws Exception{
		File path = new File (dossier_index);
		Directory directory = FSDirectory.open(path);
		IndexWriterConfig config = new IndexWriterConfig(Version.LUCENE_47, analyzer);
	    config.setOpenMode(openMode);//config.setOpenMode(OpenMode.CREATE_OR_APPEND);
	    IndexWriter iwriter = new IndexWriter(directory, config);
	    //Normalizer frenchLemmatizer = new FrenchLemmatizer();
	    
	    BufferedReader br = null;
		String lines = "";
		
		try {
			br = new BufferedReader(new FileReader(fichier_a_indexer));
			
			int counter = 0;
			br.readLine();
			while ((lines = br.readLine()) != null) {
				Document doc = new Document();
				// use semicolon as separator
				String[] line = lines.split(separateur);
				for (int i = 0 ; i<champs.length; i++){
					line[i] = line[i].replace("\"", "") ;
				
			      char action = actions[i];
			      switch (action) {
			      case 'S':
						doc.add(new StringField (champs[i], line[i], Field.Store.YES));
			        break;
			      case 'A':
						TokenStream tokenStream = analyzer.tokenStream(champs[i], line[i]);
						doc.add(new Field("tokens", tokenStream));
			        break;
			      case 'B':
			        break; 
			      default:
			        throw new Exception("Action incorrecte pour stocker le champs");
			      }
				}
				/* voir comment Lucene Tokenise : 
				tokenStream.reset();
				while (tokenStream.incrementToken()) {
				    CharTermAttribute charTermAttribute = tokenStream.addAttribute(CharTermAttribute.class);
				    String term = charTermAttribute.toString();
				    System.out.println("\t" + term);    
				}
				System.out.print("\n");
				tokenStream.close();
				*/

				iwriter.addDocument(doc);
				counter ++ ;
				
				/*
				if (counter == 10){
					break;
				}*/


			}
			System.out.println("counter = " + counter);
			iwriter.close();
		    directory.close();
		    
		} catch (FileNotFoundException e) {
			e.printStackTrace();
		} catch (IOException e) {
			e.printStackTrace();
		} finally {
			if (br != null) {
				try {
					br.close();
				} catch (IOException e) {
					e.printStackTrace();
				}
			}
		}
	}
}
