package main

/* Ce script produit automatiquement les tableaux de décharge
 à partir d’un modèle et d’un fichier composé ainsi :

 | Syndicat | Quotité proposée |
 | Ain (01) | 0,567            |
 | Total    | 2,558            |

Tous les fichiers, en entrée comme en sortie, sont des XLSX. */

// TODO
// → Gestion des options : fonction qui donne l'usage du programme
// → créer une option export avec le nom d'un dossier avec "export" comme défaut
// → Fonction spécialisée pour ouvrir les fichiers
// Identifier "Feuille1"
// → Protéger feuille

import (
	"flag"
	"fmt"
	"os"
	"path"
	"strconv"
	"sync"

	"github.com/360EntSecGroup-Skylar/excelize"
)

// Gérer les goroutines
var wg sync.WaitGroup

var (
	sha1ver   string // identifiant version Git
	buildTime string // quand le programme est compilé
)

func main() {
	var (
		quotite      string
		versionFlag  bool
		passwordFlag string
	)
	flag.StringVar(&quotite, "q", "", "Fichier quotité")
	flag.BoolVar(&versionFlag, "v", false, "Print version info and exit.")
	flag.StringVar(&passwordFlag, "p", "pandace", "Mot de passe de protection des cellules, défaut pandace")
	flag.Parse()
	if versionFlag {
		fmt.Printf("Date de compilation : %s\nIdentifiant de version : %s", buildTime, sha1ver)
		os.Exit(0)
	}
	if quotite == "" {
		fmt.Println("Option -q manquante")
		flag.PrintDefaults()
		os.Exit(1)
	}
	template := flag.Arg(0)
	if template == "" {
		fmt.Println("Donnez le nom du modèle")
		flag.PrintDefaults()
		os.Exit(1)
	}
	base := make(map[string]string)
	base = loadSyndicats(quotite)
	fmt.Println(base)
	fmt.Println(quotite)

	// Si le dossier export existe, on le bousille
	export := path.Join("./", "export")
	if _, err := os.Stat(export); !os.IsNotExist(err) {
		fmt.Println("On détruit le dossier export.")
		if os.RemoveAll(export) != nil {
			fmt.Println("Problème à la suppression.")
			os.Exit(1)
		}
	}
	// et on recrée un dossier vide
	os.Mkdir(export, 0744)

	for syndicat, decharge := range base {
		wg.Add(1)
		go genereTableau(template, export, syndicat, decharge, passwordFlag)
	}
	wg.Wait()

}

// fonction qui prend en argument un nom de fichier
// qui renvoie une map avec la quotité par syndicat
func loadSyndicats(fichierQuotite string) map[string]string {
	baseSyndicats := make(map[string]string)
	f, err := excelize.OpenFile(fichierQuotite)
	if err != nil {
		os.Exit(1)
	}
	rows := f.GetRows("Feuille1")
	// Ignore		  1re ligne    dernière ligne du fichier
	for _, row := range rows[1 : len(rows)-1] {
		baseSyndicats[row[0]] = row[1]
	}
	return baseSyndicats
}

// produire le tableau de décharge pour un syndicat
func genereTableau(cheminTemplate string, outputFolder string, syndicat string, decharge string, pass string) {
	f, err := excelize.OpenFile(cheminTemplate)
	if err != nil {
		fmt.Println("Problème à l'ouverture du fichier")
		os.Exit(1)
	}
	f.SetCellValue("Feuille1", "A64", syndicat)
	dechargeFlt, _ := strconv.ParseFloat(decharge, 64)
	f.SetCellValue("Feuille1", "B64", dechargeFlt)
	// force le recalcul au démarrage du tableur. Sinon pas d'actualisation
	f.UpdateLinkedValue()
	var protection excelize.FormatSheetProtection
	protection.Password = pass

	f.ProtectSheet("Feuille1", &protection)
	f.SaveAs(path.Join("export", syndicat+".xlsx"))
	fmt.Println(path.Join("export", syndicat+".xlsx"))
	wg.Done()

	return
}
