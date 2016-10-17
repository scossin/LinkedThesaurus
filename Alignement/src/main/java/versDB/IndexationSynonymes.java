package versDB;

import org.apache.lucene.index.IndexWriterConfig.OpenMode;
import luceneClasses.MeshCSVIndexer;
import luceneClasses.MonNormaliser;

/*
 * Cette classe index les libellés : du thesaurus, lib préférés de l'UMLS et leurs synonymes
 * Les libellés de DB sont ensuite recherchés dans cette index
 */
public class IndexationSynonymes {

	public static void main(String[] args) throws Exception {
		// TODO Auto-generated method stub

		// Normalisation : 
		String fichier_a_normaliser = "data/versDB/dci_CUI_termes_libprincipaux.csv";
		String fichier_normaliser = "data/versDB/dci_CUI_termes_libprincipaux_normaliser.csv";
		int colonne_libelle = 1 ;
		String separateur = "\t";
		System.out.println("Normalisation du fichier :" + fichier_a_normaliser);
		MonNormaliser.normalize_fichier(fichier_a_normaliser,fichier_normaliser,colonne_libelle, separateur);
		
		// Indexation
			String dossier_index=  "Index_Drug_UMLS";
			String fichier_a_indexer = fichier_normaliser;
			String[] champs= {"code","libelle", "tokens"};
			// Action S = StringField ; Action A : Analyser ; B = Break, le champs ne sera pas indexé
			char[] actions = {'S','S','A'};
			MeshCSVIndexer indexer = new MeshCSVIndexer(fichier_a_indexer, dossier_index, champs, separateur, actions, OpenMode.CREATE);
			indexer.index_File();
			System.out.println("Fichier : " + fichier_a_indexer + " a été indexé");
	}

}
