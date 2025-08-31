# Käivita script
```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/antsmartti/scriptyscript/refs/heads/main/n8n-watchtower/n8n.sh)"
```

### Mida saab n8n abil teha?
Automatsioonid kõikvõimalike protsesside jaoks. 
<br>[Integratsioonid](https://n8n.io/integrations/) | [Templates](https://n8n.io/workflows/) | [n8engine Community Nodes](https://n8engine.com/community-nodes?sortDir=desc&sortCol=totalDownloads) | [npm Community Nodes](https://www.npmjs.com/search?q=keywords%3An8n-community-node-package)

#### n8n + AI = ❤️
Tänu AI lisamise võimalusele saab ehitada kergelt ka AI agente. Kui chatGPT API võtit ei ole, siis tasub uurida tasuta Google Gemini API võtit testimise käigus. 
<br>[Hinnakiri ja limiidid](https://ai.google.dev/gemini-api/docs/pricing) | [Google AI Studio](https://aistudio.google.com)

### Miks Watchtower?
Kuna tegemist on aktiivselt arendatava rakendusega, siis watchtower kontrollib kord ööpäevas (86400 sekundi järel) kas mõni konteiner vajab uuendust või ei. Saad perioodi muuta *docker-compose.yaml* failis `command: --interval 86400`

