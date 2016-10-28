package versDB;

import java.io.BufferedReader;
import java.io.FileReader;
import java.io.IOException;
import java.nio.charset.Charset;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.List;

import luceneClasses.MeshIndexSearcher;
import luceneClasses.MonNormaliser;

/*
 * Cette classe permet d'aligner deux sources sur les substances 
 * La premier source est contenue dans un fichier
 * La deuxième source est contenue dans un index Lucene
 */


public class Alignement_drugs {

	private String fichier_in = null;
	private String fichier_out = null;
	private MeshIndexSearcher meshIndexSearcher=null;
	List<String> alignement = new ArrayList<String>();
	
	public Alignement_drugs(String fichier_in, String fichier_out, String index) throws IOException{
		this.fichier_in = fichier_in;
		this.fichier_out = fichier_out;
		meshIndexSearcher = new MeshIndexSearcher(index);
	}
	
	     // spécial DCI substance mapping
	public void set_alignement_dci(int max_resultat) throws IOException{
		List<String> nouvelles_lignes = new ArrayList<String>();
	    BufferedReader br = null;
		String lines = "";
		String proposition = "";
		
		try {
			br = new BufferedReader(new FileReader(fichier_in));
			while ((lines = br.readLine()) != null) {
			// recherche terme exact
			proposition = meshIndexSearcher.search_exact_term(lines, "libelle",1);
			if (!proposition.equals(lines + "\t" + "pas trouvé")){
				nouvelles_lignes.add(proposition);
			}
			// recherche par token
			proposition = meshIndexSearcher.search_term(lines, "tokens",max_resultat);
			nouvelles_lignes.add(proposition);
			
			// recherche fuzzy
			/* je désactive la recherche fuzzy
			if (proposition.equals(lines + "\t" + "pas trouvé")){
				proposition = meshIndexSearcher.search_fuzzy(lines, "tokens", 1, 1);
				nouvelles_lignes.add(proposition);
			}
			*/

	}
		} finally{
			br.close();
		}	
		alignement = nouvelles_lignes;
	}
	
	// spécial sniiram
	public void set_alignement_sniiram(int max_resultat ) throws IOException{
		List<String> nouvelles_lignes = new ArrayList<String>();
	    BufferedReader br = null;
		String lines = "";
		String proposition = "";
		
		try {
			br = new BufferedReader(new FileReader(fichier_in));
			while ((lines = br.readLine()) != null) {
			// recherche terme exact
			proposition = meshIndexSearcher.search_exact_term(lines, "libelle",1);
			if (!proposition.equals("pas trouvé")){
				nouvelles_lignes.add(proposition );
			}
			if (proposition.equals("pas trouvé")){
				proposition = meshIndexSearcher.search_fuzzy(lines, "tokens", 1, 1);
				nouvelles_lignes.add(proposition );
			}
			// recherche precise ingrédient
			String normal = MonNormaliser.normalise(lines); 
			proposition = meshIndexSearcher.search_term_sniiram(lines, normal, "tokens",max_resultat);
			nouvelles_lignes.add(proposition );
	}
		} finally{
			br.close();
		}	
		alignement = nouvelles_lignes;
	}
	
	     // spécial pour l'UMLS
	void set_alignement_UMLS() throws IOException{
		List<String> nouvelles_lignes = new ArrayList<String>();
	    BufferedReader br = null;
		String lines = "";
		String proposition = "";
		
		try {
			br = new BufferedReader(new FileReader(fichier_in));
			while ((lines = br.readLine()) != null) {
			proposition = meshIndexSearcher.search_exact_term(lines, "libelle",1);
			if (proposition.equals(lines + "\t" + "pas trouvé")){
				proposition = meshIndexSearcher.search_term(lines, "tokens",1);
			}
			nouvelles_lignes.add(proposition);	
	}
		} finally{
			br.close();
		}	
		alignement = nouvelles_lignes;
	}
	
	
	public void set_alignement() throws IOException{
		List<String> nouvelles_lignes = new ArrayList<String>();
	    BufferedReader br = null;
		String lines = "";
		String proposition = "";
		int counter = 0;
		try {
			br = new BufferedReader(new FileReader(fichier_in));
			
			while ((lines = br.readLine()) != null) {
		counter ++;
		proposition = meshIndexSearcher.search_exact_term(lines, "libelle",1);
			if (proposition.equals(lines + "\t" + "pas trouvé")){
				//normaliser
				String normal = MonNormaliser.normalise(lines); 
				proposition = meshIndexSearcher.search_term(normal, "tokens",1);
			}
			nouvelles_lignes.add(proposition);
		} 	
	}
		finally{
			br.close();
			System.out.println(counter + " mots recherchés");
		}	
		alignement = nouvelles_lignes;
	}
	
	public void writeProposition() throws IOException{
		Path file = Paths.get(fichier_out);
		Files.write(file, alignement, Charset.forName("UTF-8"));
		System.out.println("nouveau fichier : " + fichier_out);
	}
}
