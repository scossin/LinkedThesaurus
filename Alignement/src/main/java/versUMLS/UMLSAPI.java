package versUMLS;
import java.io.BufferedReader;
import java.io.FileReader;
import java.io.IOException;
import java.nio.charset.Charset;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardOpenOption;
import java.util.ArrayList;
import java.util.List;

import gov.nih.nlm.uts.webservice.AtomDTO;
import gov.nih.nlm.uts.webservice.UiLabel;
import gov.nih.nlm.uts.webservice.UtsFault_Exception;
import gov.nih.nlm.uts.webservice.UtsWsContentController;
import gov.nih.nlm.uts.webservice.UtsWsContentControllerImplService;
import gov.nih.nlm.uts.webservice.UtsWsFinderController;
import gov.nih.nlm.uts.webservice.UtsWsFinderControllerImplService;
import gov.nih.nlm.uts.webservice.UtsWsSecurityController;
import gov.nih.nlm.uts.webservice.UtsWsSecurityControllerImplService;


// ******************************* Cette classe se connecte à l'UMLS API************* //
/* 
 * Elle contient trois principales fonctions : 
 * 1) retrouver les concepts UMLS à partir d'un terme
 * 2) rechercher les libellés UMLS à partir d'un concept UMLS (CUI)
 * 3) rechercher les codes RxNorm 
 */

public class UMLSAPI {
			// Pour la connexion : créer une classe Global.java et les variables username et password de l'UMLS
	private String username = UMLSconfig.USERNAME;
	private String password = UMLSconfig.PWD;
	protected String umlsRelease = "2015AB";
	public String serviceName = "http://umlsks.nlm.nih.gov";
	protected UtsWsContentController utsContentService ;
	public UtsWsSecurityController securityService ;
	public String singleUseTicket1 ;
	public UtsWsFinderController utsFinderService;
	
		// Pour sélectionner la source
	protected gov.nih.nlm.uts.webservice.Psf myPsffinder ; 
    protected gov.nih.nlm.uts.webservice.Psf myPsfcontent ; 

         //Pour sélectionner la source
    private gov.nih.nlm.uts.webservice.Psf myPsfcontentFREEN1000 ; 

			// Constructeur :
	public UMLSAPI () throws UtsFault_Exception {
		utsContentService = (new UtsWsContentControllerImplService()).getUtsWsContentControllerImplPort();
        securityService = (new UtsWsSecurityControllerImplService()).getUtsWsSecurityControllerImplPort();
        myPsffinder = new gov.nih.nlm.uts.webservice.Psf();
        myPsfcontent = new gov.nih.nlm.uts.webservice.Psf();
        utsFinderService = (new UtsWsFinderControllerImplService()).getUtsWsFinderControllerImplPort();
        
        // 
        // Français et anglais seulement
        myPsfcontentFREEN1000 = new gov.nih.nlm.uts.webservice.Psf();
        myPsfcontentFREEN1000.setIncludedLanguage("FRE");
        myPsfcontentFREEN1000.setIncludedLanguage("ENG");
		// 1000 résultats par page
        myPsfcontentFREEN1000.setPageLn(1000);
        
	}
	
		// Cette fonction est importante car un ticket est nécessaire pour chaque requête à l'API
	public void ticket () throws UtsFault_Exception {
        //get the Proxy Grant Ticket - this is good for 8 hours and is needed to generate single use tickets.
        String ticketGrantingTicket = securityService.getProxyGrantTicket(username, password);
        this.singleUseTicket1 = securityService.getProxyTicket(ticketGrantingTicket, serviceName);
	}
	
	// retrouve le code RxNorm pour un CUI donné
	public String search_RxNorm(String CUI) throws UtsFault_Exception{
	   String output = null;
		//myPsfcontent.getIncludedSources().add("SNOMEDCT_US");
	   myPsfcontent.getIncludedSources().add("RXNORM");
	   ticket();	
	    List<AtomDTO> atoms = new ArrayList<AtomDTO>();
	    //List<String> nouvelles_lignes = new ArrayList<String>();
	    atoms = utsContentService.getConceptAtoms(singleUseTicket1, umlsRelease, CUI, myPsfcontent);
	    //System.out.println(atoms.size());    
	    if (atoms.size() != 0 ){
		    for (AtomDTO atom:atoms) { 		
		    String aui = atom.getUi();
		    String tty = atom.getTermType();
		    String name = atom.getTermString().getName();
		    String sourceId = atom.getCode().getUi();
		    String rsab = atom.getRootSource();
		    output = CUI + "\t" + aui + "\t" + tty + "\t" + name + "\t" + sourceId + "\t" + rsab;
		    // une seule ligne
		    break;
		    }
	    } else {
	    	// non trouve : -999
	    	output = (CUI + "\t" + "-999");
	    }
	    System.out.println(output);
	    return (output);
	}
	
	// fichier en entrée : liste de CUI ; fichier en sortie : liste de code RxNorm
	public void search_RxNorm_file (String fichierCUI, String nom_fichier_Rxnorm) throws IOException, UtsFault_Exception {
		BufferedReader br = null;
		String lines = "";
	    br = new BufferedReader(new FileReader(fichierCUI));
	    while ((lines = br.readLine()) != null) {
			List<String> nouvelles_lignes = new ArrayList<String>();
			nouvelles_lignes.add(search_RxNorm(lines));
			write_fichier_mapper(nom_fichier_Rxnorm,nouvelles_lignes);
		}
	    br.close();
	}
	
	// Cherche un concept UMLS à partir d'un terme
	public String search_concept (String terme) throws UtsFault_Exception {
		
		AtomDTO myAtom = null;
		List<UiLabel> results = new ArrayList<UiLabel>();
		// Recherche un atome contenant ce terme précis
		ticket();
		//myPsffinder.setPageNum(1);
		//myPsffinder.getIncludedSources().add("SNOMEDCT_US");
	    results = utsFinderService.findAtoms(singleUseTicket1, umlsRelease, "atom", terme, "words", myPsffinder);
		String output = null   ;  
	           if (results.size() != 0){
		 		 for (UiLabel result:results) {
					    String ui_atome = result.getUi();
					    String name_atome = result.getLabel();
					    ticket();
					    myAtom = utsContentService.getAtom(singleUseTicket1, umlsRelease, ui_atome);
				        String conceptUi = myAtom.getConcept().getUi();
				        String conceptName = myAtom.getConcept().getDefaultPreferredName(); 
				        String source = myAtom.getRootSource();
				        output = terme + "\t" + ui_atome + "\t" + source + "\t" + name_atome + "\t" + conceptUi + "\t" + conceptName ;
					    // On prend que le premier
					    break;
					} 
		     } else {
		    	 output = terme + "\t non trouvé";
		     }
	      System.out.println(output);
		  return (output);   
	}
	
	// fichier en entrée : liste de termes ; fichier en sortie : liste de termes avec leur CUI
	public void search_concept_file (String nom_fichier, String nom_fichier_mapper) throws IOException, UtsFault_Exception{
		List<String> nouvelles_lignes = new ArrayList<String>();
		BufferedReader br = null;
		String lines = "";
	    br = new BufferedReader(new FileReader(nom_fichier));
	    while ((lines = br.readLine()) != null) {
			nouvelles_lignes.add(search_concept(lines));
		}
	    br.close();
	    write_fichier_mapper(nom_fichier_mapper, nouvelles_lignes);
	}
	
	// permet de retrouver les synonymes d'un CUI en anglais et en francais
	public List<String> synonymesCUI(String CUI) throws UtsFault_Exception{
		List<AtomDTO> atoms = new ArrayList<AtomDTO>();
	    ticket();
	    atoms = utsContentService.getConceptAtoms(singleUseTicket1, umlsRelease, CUI, myPsfcontentFREEN1000);
	    // Synonymes uniques
	    List<String> synonymes = new ArrayList<String>();
	    //System.out.println(atoms.size());	
	    if (atoms.size() != 0){
		    for (AtomDTO atom:atoms) {		
			    //String aui = atom.getUi();
			    //String tty = atom.getTermType();
			    String name = atom.getTermString().getName();
			    //String sourceId = atom.getCode().getUi();
			    //String rsab = atom.getRootSource();
			    String entree = CUI + "\t" + name.toLowerCase() ;
			    if (!synonymes.contains(entree)){
			    	synonymes.add(entree);
			    	System.out.println(entree);
			    }
			    	
			    }
	    } else {
	    	synonymes.add(CUI + "\t" + "aucun synonyme");
	    }
		
	    return(synonymes);
	}
	
	// en entrées : liste de CUI, en sortie : liste des synonymes de ce synonyme
	public void synonymesCUI_file(String nom_fichier_CUI, String nom_fichier_CUI_termes) throws IOException, UtsFault_Exception{
		BufferedReader br = null;
		String lines = "";
	    br = new BufferedReader(new FileReader(nom_fichier_CUI));
	    while ((lines = br.readLine()) != null) {
		    write_fichier_mapper(nom_fichier_CUI_termes, synonymesCUI(lines));
		}
	    br.close();

	}
	
	private void write_fichier_mapper(String nom_fichier_mapper, List<String> nouvelles_lignes) throws IOException{
		Path file = Paths.get(nom_fichier_mapper);
		Files.write(file, nouvelles_lignes, Charset.forName("UTF-8"), StandardOpenOption.APPEND);
	}
	
	public static void main (String args[]) throws UtsFault_Exception{
   
		UMLSAPI umls = new UMLSAPI();
		umls.ticket();
		
		// Recherche un concept via un terme
		umls.search_concept("Acebutolol");
		
		// Recherche un code UMLS via un CUI
		umls.search_RxNorm("C0000946");
		
		// Recherche les synonymes d'un concpets : 
		umls.synonymesCUI("C0373527");
        
	}

	}

