### Architecture

- LLM AutoHotkey Assistant.ahk : Le script principal

- lib : Les fichiers contenant les fonctionnalités appelées par LLM AutoHotkey Assistant.ahk
- lib\Response Window.ahk : 
    - C'est un script à part entière, lancé par LLM AutoHotkey Assistant.ahk
    - Il représente une fenêtre de discussion avec un LLM.
    - Il y en a autant que de discusssions en parallèle avec des LLM
- lib\simulate_select.ahk est un petit script lancé après affichage du menu pour sélectionner automatiquement le premier item.

- lib\MainScript : Les fichiers de fonctions inclus par LLM AutoHotkey Assistant.ahk
- lib\ResponseWindow : Les fichiers de fonctions inclus par lib\Response Window.ahk
- lib\Shared : Les fichiers de fonctions inclus, à la fois, par LLM AutoHotkey Assistant.ahk et lib\Response Window.ahk

- lib\Response Window resources : Fichiers de configuration de la page web affichée par Response Window.ahk

### Règles spécifique à ce projet

- Les Commentaires doivent être rédigés en Anglais.
- Les merges Git doivent TOUJOURS être effectués avec `--no-ff` (interdiction formelle des merges fast-forward).
