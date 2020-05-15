# tabdecharge

Un programme en Go destiné à générer automatiquement les tableaux de décharge des syndicats avec leur quotité de décharge pré-remplie.



## Usage



`tabdecharge -q quotité.xlsx template.xlsx`



`-q` ou `–quotite` est obligatoirement suivi du chemin vers le un XLSX structuré ainsi :



|      | A         | B                |
| ---- | --------- | ---------------- |
| 1    | Syndicat  | Quotité proposée |
| 2    | Ain (01)  | 0,453            |
| 3    | Aine (02) | 0,489            |
| 4    | Total     | 26,489           |



Les en-têtes de colonne doivent être présentes, de même qu’une ligne « total » à la fin. Le programme parcourt lignes de la deuxième à l’avant-dernière.

`template.xlsx` est un fichier XLSX qui sert de modèle. Ce fichier sera ouvert et modifié puis enregistré en série.



## Compilation

Le script `construire` permet de compiler le programme.

Pour avoir une idée de quelles plateformes sont supportées, utilisez la commande `go tool dist list`