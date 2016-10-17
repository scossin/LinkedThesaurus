package versDB;

import java.io.IOException;

public class DBtoUMLS {

	/*
	 * Cette classe permet de rechercher des libellés DB dans l'index : Cf IndexationSynonymes
	 */
	
	public static void main(String[] args) throws IOException {
		// TODO Auto-generated method stub
	    
		String libellesDB = "data/versDB/libellesDB.txt";
		String proposition = "data/versDB/libellesDBmapper.txt";
		
		Alignement_drugs alignement = new Alignement_drugs(libellesDB, proposition, "Index_Drug_UMLS", null);
		alignement.set_alignement();
		alignement.writeProposition();
	}

}
