# Käivita script
```bash
bash -c "$(curl -fsSL https://sh.anexos.ee/n8n)"
```

### Mida saab n8n abil teha?
Automatsioonid kõikvõimalike protsesside jaoks. 
<br>[Integratsioonid](https://n8n.io/integrations/) | [Templates](https://n8n.io/workflows/) | [Community Nodes](https://n8engine.com/community-nodes?sortDir=desc&sortCol=totalDownloads)

#### n8n + AI = ❤️
Tänu AI lisamise võimalusele saab ehitada kergelt ka AI agente. Kui chatGPT API võtit ei ole, siis tasub uurida tasuta Google Gemini API võtit testimise käigus. 
<br>[Hinnakiri ja limiidid](https://ai.google.dev/gemini-api/docs/pricing) | [Google AI Studio](https://aistudio.google.com)

### Miks Watchtower?
Kuna tegemist on aktiivselt arendatava rakendusega, siis watchtower kontrollib kord ööpäevas (86400 sekundi järel) kas mõni konteiner vajab uuendust või ei. Saad perioodi muuta *docker-compose.yaml* failis `command: --interval 86400`

