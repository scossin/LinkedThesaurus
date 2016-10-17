package versSNIIRAM;

import org.apache.lucene.index.IndexWriterConfig.OpenMode;

import luceneClasses.MeshCSVIndexer;
import luceneClasses.MonNormaliser;

/*
 * molecules du referentiel SNIIRAM
 */
public class indexationSNIIRAM {

	public static void main(String[] args) throws Exception {
		// TODO Auto-generated method stub
		// Normalisation : 
		String fichier_a_normaliser = "data/versSNIIRAM/moleculessniiram.csv";
		String fichier_normaliser = "data/versSNIIRAM/moleculessniiram_normaliser.csv";
		int colonne_libelle = 0 ;
		String separateur = "\t";
		System.out.println("Normalisation du fichier :" + fichier_a_normaliser);
		MonNormaliser.normalize_fichier(fichier_a_normaliser,fichier_normaliser,colonne_libelle, separateur);
		
			String dossier_index=  "index_sniiram";
			String fichier_a_indexer = fichier_normaliser;
			String[] champs= {"libelle", "tokens"};
			// Action S = StringField ; Action A : Analyser ; B = Break, le champs ne sera pas indexé
			char[] actions = {'S','A'};
			MeshCSVIndexer indexer = new MeshCSVIndexer(fichier_a_indexer, dossier_index, champs, separateur, actions, OpenMode.CREATE);
			indexer.index_File();
			System.out.println("Fichier : " + fichier_a_indexer + " a été indexé");
	}

}
