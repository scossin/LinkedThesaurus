# LinkedThesaurus
Link the thesaurus of drug interactions edited by ANSM to UMLS, to DrugBank and to the [repertoire des médicaments](http://agence-prd.ansm.sante.fr/php/ecodex/telecharger/telecharger.php), a french drug database edited by ANSM

## Installation
This folder contains a maven project. It uses UMLS SOAP API : https://documentation.uts.nlm.nih.gov/soap/home.html
The settings.xml file of maven must be configured, otherwise you'll have a Missing artifact error. 

### Command for linux :
```sh
sudo apt install maven
cd /usr/share/maven
cp settings.xml ~/.m2/settings.xml
```

Then add these lines below to the ~/.m2/settings.xml file
```xml
<settings>
  <servers>
    <server>
      <id>FTP-SERVER</id>
      <username>anonymous</username>
      <password></password>
    </server> 
  </servers>
</settings>
```

Then Update the maven project. To use the UMLS SOAP API, register online and create a JAVA class "UMLSconfig.class" containing username and password (see UMLSconfigExample.java)
