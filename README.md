<div align="center">
   <img src=".github/assets/logo.png" alt="Logo" width="300">
   <br><a href="https://github.com/apurvsinghgautam/robin/actions/workflows/release.yml"><img alt="Release" src="https://github.com/apurvsinghgautam/robin/actions/workflows/release.yml/badge.svg"></a> <a href="https://github.com/apurvsinghgautam/robin/releases"><img alt="GitHub Release" src="https://img.shields.io/github/v/release/apurvsinghgautam/robin"></a> <a href="https://hub.docker.com/r/apurvsg/robin"><img alt="Docker Pulls" src="https://img.shields.io/docker/pulls/apurvsg/robin"></a>
   <h1>Robin: AI-Powered Dark Web OSINT Tool</h1>

   <p>Robin is an AI-powered tool for conducting dark web OSINT investigations. It leverages LLMs to refine queries, filter search results from dark web search engines, and provide an investigation summary.</p>
   <a href="#installation">Installation</a> &bull; <a href="#usage">Usage</a> &bull; <a href="#contributing">Contributing</a> &bull; <a href="#acknowledgements">Acknowledgements</a><br><br>
</div>

![Demo](.github/assets/screen-ui.png)


## Architecture
![Workflow](.github/assets/robin-workflow.png)

---

## Features

- ⚙️ **Modular Architecture** – Clean separation between search, scrape, and LLM workflows.
- 🤖 **Multi-Model Support** – Easily switch between OpenAI, Claude, Gemini, Ollama, or any OpenAI-compatible API (LM Studio, llama.cpp, Groq, etc.).
- 🌐 **Web UI** – Streamlit-based interface for interactive investigations.
- 🐳 **Docker-Ready** – Recommended Docker deployment for clean, isolated usage.
- 📝 **Custom Reporting** – Save investigation output to file for reporting or further analysis.
- 🧩 **Extensible** – Easy to plug in new search engines, models, or output formats.

---

## ⚠️ Disclaimer
> This tool is intended for educational and lawful investigative purposes only. Accessing or interacting with certain dark web content may be illegal depending on your jurisdiction. The author is not responsible for any misuse of this tool or the data gathered using it.
>
> Use responsibly and at your own risk. Ensure you comply with all relevant laws and institutional policies before conducting OSINT investigations.
>
> Additionally, Robin leverages third-party APIs (including LLMs). Be cautious when sending potentially sensitive queries, and review the terms of service for any API or model provider you use.

## Installation
> [!NOTE]
> The tool needs Tor to do the searches. You can install Tor using `apt install tor` on Linux/Windows(WSL) or `brew install tor` on Mac. Once installed, confirm if Tor is running in the background.

> [!TIP]
> You can provide your LLM of choice API key by either creating .env file (refer to sample env file in the repo) or by setting env variables in PATH.
>
> For Ollama, provide `http://host.docker.internal:11434` as `OLLAMA_BASE_URL` in your env if running using docker method or `http://127.0.0.1:11434` for other methods. You might need to serve Ollama on 0.0.0.0 depending on your OS. You can do by running `OLLAMA_HOST=0.0.0.0 ollama serve &` in your terminal.
>
> For any other OpenAI-compatible provider (LM Studio, llama.cpp, Groq, etc.), use the **🔌 Custom API Provider** expander in the sidebar — no `.env` changes required. Enter the base URL, an optional API key, and optionally a model name if the provider doesn't expose `/v1/models` for auto-discovery.

### Docker [Recommended]

- Pull the latest Robin docker image
```bash
docker pull apurvsg/robin:latest
```

- Run the docker image as:
```bash
docker run --rm \
   -v "$(pwd)/.env:/app/.env" \
   --add-host=host.docker.internal:host-gateway \
   -p 8501:8501 \
   apurvsg/robin:latest
```

> [!TIP]
> To persist saved investigations across Docker restarts, mount a local directory:
> ```bash
> docker run --rm \
>    -v "$(pwd)/.env:/app/.env" \
>    -v "$(pwd)/investigations:/app/investigations" \
>    --add-host=host.docker.internal:host-gateway \
>    -p 8501:8501 \
>    apurvsg/robin:latest
> ```
> Investigations are saved to the `investigations/` folder in your working directory and can be loaded from the **Past Investigations** panel in the sidebar.

- Open your browser and navigate to `http://localhost:8501`

### Using Python (Development Version)

- With `Python 3.10+` and Tor installed, run the following:

```bash
pip install -r requirements.txt
streamlit run ui.py
```

- Open your browser and navigate to `http://localhost:8501`

### Self-hosted with Docker Compose

The image bundles Tor, so nothing needs to be installed on the host beyond Docker.

```bash
cp .env.example .env   # add your LLM API keys
docker compose up --build
```

Open `http://localhost:8501`. Investigations persist in the `investigations/` folder.

---

## Cloud Deployment (no local install)

Robin ships as a single self-contained image (Tor + Streamlit), so it can run on any
container host and be reached through a public URL — nothing to install on your machine.
The container reads the platform-provided `$PORT` (falling back to `8501` locally) and
binds to `0.0.0.0`. Add your LLM API keys as environment variables / secrets on the
platform, or use the **🔌 Custom API Provider** expander in the sidebar at runtime.

### Render [one-click]

The repo includes a [`render.yaml`](render.yaml) Blueprint.

1. Fork/push this repo to GitHub.
2. On [Render](https://render.com), choose **New + → Blueprint** and select the repo.
3. Render builds the Docker image and serves the app at `https://<name>.onrender.com`.
4. Add your LLM API keys under the service's **Environment** tab.

> [!NOTE]
> The free instance type sleeps after inactivity; the first request (and Tor bootstrap)
> may take ~30–60s to wake up.

### Fly.io

The repo includes a [`fly.toml`](fly.toml).

```bash
fly auth login
fly launch --copy-config --no-deploy   # pick a unique app name
fly secrets set OPENAI_API_KEY=... ANTHROPIC_API_KEY=...
fly deploy
```

The app is served at `https://<app-name>.fly.dev`.

### Google Cloud Run

```bash
gcloud run deploy robin \
  --source . \
  --port 8080 \
  --allow-unauthenticated \
  --memory 1Gi \
  --set-env-vars OPENAI_API_KEY=...
```

Cloud Run injects `$PORT=8080`, which the entrypoint honours. The returned
`https://robin-xxxxx.run.app` URL is your public app.

> [!NOTE]
> Cloud Run scales to zero; cold starts pay the Tor bootstrap latency. Use
> `--min-instances 1` to keep an instance warm.

---

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request if you have major feature updates.

- Fork the repository
- Create your feature branch (git checkout -b feature/amazing-feature)
- Commit your changes (git commit -m 'Add some amazing feature')
- Push to the branch (git push origin feature/amazing-feature)
- Open a Pull Request

Open an Issue for any of these situations:
- If you spot a bug or bad code
- If you have a feature request idea
- If you have questions or doubts about usage
- If you have minor code changes

---

## Acknowledgements

- Idea inspiration from [Thomas Roccia](https://x.com/fr0gger_) and his demo of [Perplexity of the Dark Web](https://x.com/fr0gger_/status/1908051083068645558).
- Tools inspiration from my [OSINT Tools for the Dark Web](https://github.com/apurvsinghgautam/dark-web-osint-tools) repository.
- LLM Prompt inspiration from [OSINT-Assistant](https://github.com/AXRoux/OSINT-Assistant) repository.
- Logo Design by my friend [Tanishq Rupaal](https://github.com/Tanq16/)






