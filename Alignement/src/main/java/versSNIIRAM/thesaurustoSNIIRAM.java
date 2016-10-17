package versSNIIRAM;

import java.io.IOException;

import versDB.Alignement_drugs;

public class thesaurustoSNIIRAM {

	public static void main(String[] args) throws IOException {
		// TODO Auto-generated method stub
		String moleculesthesaurus = "data/versSNIIRAM/moleculesthesaurus.txt";
		String proposition = "data/versSNIIRAM/moleculesthesaurusproposition.txt";
		
		Alignement_drugs alignement = new Alignement_drugs(moleculesthesaurus, proposition, "index_sniiram", null);
		alignement.set_alignement_sniiram(10);
		//alignement.writeProposition();
	}

}
