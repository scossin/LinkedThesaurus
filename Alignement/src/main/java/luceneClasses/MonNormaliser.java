package luceneClasses;

import java.io.BufferedReader;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.IOException;
import java.nio.charset.Charset;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.text.Normalizer;
import java.util.ArrayList;
import java.util.List;

public class MonNormaliser {

	public static String normalise(String s){
		// remove accents
		String string = Normalizer.normalize(s, Normalizer.Form.NFD);
		string = string.replaceAll("[^\\p{ASCII}]", "");
		
		// remove punctuation
		string = string.replaceAll("\\p{P}", " ");
		
		// remove multispace
		string = string.replaceAll("[ ]+", " ");
		string = string.replaceAll("^[ ]", "");
		
		// bizarrememnt cela peut arriver 
		string = string.replaceAll("\t$", "");
		// en minuscule :
		string = string.toLowerCase();
		
		return (string);
	}
	
	public static void main (String[] args){
		String test = "Ceci n'é pas un testé à -                     réalisé";
		String string = MonNormaliser.normalise(test);
		System.out.println(string);
	}
	
	public static void normalize_fichier (String fichier_a_normaliser, String fichier_normaliser, int colonne_a_normaliser,
			String separateur) throws IOException{
		List<String> nouvelles_lignes = new ArrayList<String>();
		BufferedReader br = null;
		String lines = "";
		try {
			br = new BufferedReader(new FileReader(fichier_a_normaliser));
			while ((lines = br.readLine()) != null) {
				String[] line = lines.split(separateur);
				line[colonne_a_normaliser] = line[colonne_a_normaliser].replace("\"", "") ;
				String ligne1_normale = normalise(line[colonne_a_normaliser]);
				nouvelles_lignes.add(lines + separateur + "\"" + ligne1_normale + "\"");
			}		
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
		Path file = Paths.get(fichier_normaliser);
		Files.write(file, nouvelles_lignes, Charset.forName("UTF-8"));
		System.out.println(fichier_normaliser + " créé.");
	}	
}
