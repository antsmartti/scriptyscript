### Miks Watchtower?
Sest n8n uuendamine ei peaks olema manuaalne tegevus. Kuna tegemist on aktiivselt arendatava rakendusega, siis watchtower kontrollib kord ööpäevas (86400 sekundi järel) kas mõni konteiner vajab uuendust või ei. Saad seda muuta *docker-compose.yaml* failis `command: --interval 86400`
