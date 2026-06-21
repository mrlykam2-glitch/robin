# Guide de Déploiement de Robin sur Windows

Ce guide vous explique pas à pas comment installer, configurer et lancer **Robin (AI-Powered Dark Web OSINT Tool)** sur un système d'exploitation Windows.

---

## 📋 Prérequis Obligatoires

### 1. Activer et exécuter Tor
Robin utilise le réseau Tor pour router ses requêtes de recherche sur le Dark Web de manière anonyme. Vous devez obligatoirement avoir Tor actif sur votre machine.

* **Option A : Via Winget (Recommandé - Ligne de commande Windows)**
  Ouvrez **PowerShell** en mode administrateur et exécutez :

  ```powershell
  winget install --id TorProject.TorBrowser -e
  ```

  Une fois l'installation terminée, lancez le **Navigateur Tor** depuis le menu Démarrer. Le service Tor écoute alors par défaut sur le port SOCKS5 `127.0.0.1:9050`, qui est le port attendu par Robin.

* **Option B : Via l'expert Tor (Tor Expert Bundle)**
  Si vous souhaitez uniquement le service Tor sans le navigateur, téléchargez le **Tor Expert Bundle** sur <https://www.torproject.org/download/tor/> et extrayez l'archive. Puis, dans PowerShell :

  ```powershell
  cd "C:\Tools\tor"
  .\tor.exe
  ```

  Vérifiez que Tor écoute bien sur `127.0.0.1:9050` dans les logs de démarrage.

* **Option C : Via WSL (Windows Subsystem for Linux)**
  Si vous avez WSL d'installé :

  ```bash
  sudo apt update && sudo apt install -y tor
  sudo service tor start
  # ou : tor &
  ```

  > ⚠️ Si vous utilisez WSL pour Tor, Robin (côté Windows) devra pointer vers l'IP du sous-réseau WSL plutôt que `127.0.0.1`. Préférez l'Option A ou B pour un usage natif Windows.

### 2. Vérifier que Tor est actif
Dans PowerShell, testez la connexion au port SOCKS5 :

```powershell
Test-NetConnection -ComputerName 127.0.0.1 -Port 9050
```

Le résultat doit indiquer `TcpTestSucceeded : True`. Si ce n'est pas le cas, relancez Tor avant de continuer.

### 3. Installer Python 3.10+
Robin nécessite **Python 3.10 ou supérieur**.

```powershell
winget install --id Python.Python.3.12 -e
```

Vérifiez l'installation :

```powershell
python --version
pip --version
```

### 4. (Optionnel) Installer Docker Desktop
Si vous préférez le déploiement Docker (recommandé par le projet), installez Docker Desktop :

```powershell
winget install --id Docker.DockerDesktop -e
```

Lancez Docker Desktop et attendez que le moteur Docker soit prêt.

---

## 🚀 Méthode 1 : Déploiement Docker (Recommandé)

### 1. Récupérer l'image officielle
```powershell
docker pull apurvsg/robin:latest
```

### 2. Préparer le fichier `.env`
À la racine de votre dossier de travail (ex. `C:\Projects\Robin`), créez un fichier `.env` en vous basant sur `.env.example` fourni dans le repo :

```env
OPENAI_API_KEY=sk-...
ANTHROPIC_API_KEY=...
GOOGLE_API_KEY=...
OLLAMA_BASE_URL=http://host.docker.internal:11434
OPENROUTER_BASE_URL=https://openrouter.ai/api/v1
OPENROUTER_API_KEY=...
LLAMA_CPP_BASE_URL=...
CUSTOM_API_BASE_URL=...
CUSTOM_API_KEY=...
CUSTOM_API_MODEL=...
```

> 💡 Vous n'avez besoin de renseigner **qu'un seul** fournisseur de LLM. Pour Ollama local, indiquez `http://host.docker.internal:11434` comme `OLLAMA_BASE_URL`.

### 3. Lancer le conteneur
```powershell
docker run --rm `
  -v "${PWD}/.env:/app/.env" `
  -v "${PWD}/investigations:/app/investigations" `
  --add-host=host.docker.internal:host-gateway `
  -p 8501:8501 `
  apurvsg/robin:latest
```

> 🔎 Le montage `investigations` permet de persistenter les rapports d'investigation entre les redémarrages du conteneur.

### 4. Accéder à l'interface
Ouvrez votre navigateur sur : <http://localhost:8501>

---

## 🐍 Méthode 2 : Déploiement Python (Version de développement)

### 1. Cloner le dépôt
```powershell
cd C:\Projects
git clone https://github.com/apurvsinghgautam/robin.git
cd robin
```

### 2. Créer un environnement virtuel
```powershell
python -m venv .venv
.\.venv\Scripts\Activate.ps1
```

> ⚠️ Si PowerShell bloque l'exécution du script d'activation, exécutez d'abord :
> ```powershell
> Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned
> ```

### 3. Installer les dépendances
```powershell
pip install --upgrade pip
pip install -r requirements.txt
```

Les paquets installés incluent notamment : `streamlit`, `requests`, `pysocks`, `bs4`, `python-dotenv`, et les intégrations LangChain pour OpenAI, Anthropic, Google Gemini et Ollama.

### 4. Configurer le fichier `.env`
Copiez le fichier d'exemple et éditez-le :

```powershell
Copy-Item .env.example .env
notepad .env
```

Renseignez au minimum la clé API du LLM que vous souhaitez utiliser (OpenAI, Anthropic, Google, Ollama, OpenRouter, llama.cpp, ou un fournisseur Custom compatible OpenAI).

### 5. Démarrer Tor
Assurez-vous que Tor tourne en arrière-plan sur `127.0.0.1:9050` (voir section Prérequis). Sans Tor actif, la recherche Dark Web échouera.

### 6. Lancer Robin
```powershell
streamlit run ui.py
```

Streamlit ouvre automatiquement votre navigateur sur <http://localhost:8501>. Si ce n'est pas le cas, ouvrez l'URL manuellement.

---

## 🔧 Configuration avancée

### Changer de LLM à la volée
Dans l'interface Streamlit, le panneau latéral permet de sélectionner dynamiquement le fournisseur de LLM :
- **OpenAI**, **Anthropic Claude**, **Google Gemini**, **Ollama**, **OpenRouter**, **llama.cpp**
- **🔌 Custom API Provider** : pour tout fournisseur compatible OpenAI (LM Studio, Groq, etc.). Renseignez la base URL, une clé API optionnelle, et un nom de modèle si l'auto-découverte `/v1/models` n'est pas disponible.

### Utiliser Ollama en local
1. Installez Ollama : `winget install --id Ollama.Ollama -e`
2. Lancez le service : `ollama serve`
3. Tirez un modèle : `ollama pull llama3`
4. Dans `.env` : `OLLAMA_BASE_URL=http://127.0.0.1:11434` (ou `http://host.docker.internal:11434` en Docker)

### Vérifier le routage Tor
Robin utilise un proxy SOCKS5 (`socks5h://127.0.0.1:9050`) pour toutes les requêtes vers les moteurs de recherche `.onion`. Pour confirmer que votre trafic sort bien par Tor, vous pouvez tester dans Python :

```python
import requests
proxies = {"http": "socks5h://127.0.0.1:9050", "https": "socks5h://127.0.0.1:9050"}
r = requests.get("https://check.torproject.org/api/ip", proxies=proxies)
print(r.json())
```

La réponse doit indiquer `"IsTor": true`.

---

## 🛠️ Dépannage courant

| Problème | Cause probable | Solution |
|---|---|---|
| `Connection refused on port 9050` | Tor n'est pas lancé | Démarrez Tor Browser ou `tor.exe` |
| Aucun résultat de recherche | Tor actif mais moteur `.onion` injoignable | Relancez Tor, vérifiez votre horloge système, réessayez |
| `ModuleNotFoundError` | Dépendances non installées | Exécutez `pip install -r requirements.txt` dans le venv actif |
| Erreur d'authentification LLM | Clé API manquante ou invalide | Vérifiez votre fichier `.env` |
| Streamlit inaccessible | Port 8501 déjà utilisé | Lancez avec `streamlit run ui.py --server.port=8502` |
| PowerShell bloque l'activation du venv | Politique d'exécution restrictive | `Set-ExecutionPolicy -Scope CurrentUser RemoteSigned` |

---

## ⚠️ Avertissement légal
Robin est destiné à un usage **éducatif et d'investigation légale** uniquement. L'accès ou l'interaction avec certains contenus du Dark Web peut être **illégal** selon votre juridiction. L'auteur n'est pas responsable d'une utilisation détournée de l'outil.

De plus, Robin s'appuie sur des API tierces (LLM). Évitez d'envoyer des requêtes contenant des données sensibles, et consultez les conditions d'utilisation de chaque fournisseur.

**Utilisez l'outil de manière responsable et à vos propres risques.**
