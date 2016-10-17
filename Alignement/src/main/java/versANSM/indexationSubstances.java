package versANSM;

import org.apache.lucene.index.IndexWriterConfig.OpenMode;

import luceneClasses.MeshCSVIndexer;

/*
 * Cette classe permet d'indexer les substances du répertoire des médicaments de l'ANSM
 */
public class indexationSubstances {

	public static void main(String[] args) throws Exception {
		// TODO Auto-generated method stub

		String fichier_normaliser = "data/versANSM/substancesANSM/substances_ANSM.csv";
		String separateur = "\t";
		String dossier_index=  "Index_Substances";
		String fichier_a_indexer = fichier_normaliser;
		String[] champs= {"code","libelle", "tokens"};
			// Action S = StringField ; Action A : Analyser ; B = Break, le champs ne sera pas indexé
		char[] actions = {'S','S','A'};
		MeshCSVIndexer indexer = new MeshCSVIndexer(fichier_a_indexer, dossier_index, champs, separateur, actions, OpenMode.CREATE);
		indexer.index_File();
		System.out.println("Fichier : " + fichier_a_indexer + " a été indexé");
	}

}
