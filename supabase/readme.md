## Käivita script

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/antsmartti/scriptyscript/refs/heads/main/supabase/supabase.sh)"
```

Andmebaaside paroolid genereeritakse automaatselt.

## Cloudflare seadistus
Kui uus tunnel token on genereeritud, lisa järgnevad read

<img height="240" alt="Screenshot 2025-11-26 164947" src="https://github.com/user-attachments/assets/f3c24326-805a-4beb-80a1-9a9d1b787079" />

## Võimalikud errorid
### Probleemid n8n kasutamisel
Luues Supabase jaoks credential, ei õnnestunud mul tükk aega andmeid lugeda-sisestada. Jõudsin järeldasin, et probleem on Cloudflare HTTP Header'is. Lahenduse leidsin n8n foorumist ([link](https://community.n8n.io/t/105732)). Skript PEAKS selle lahendama, kuid ei pruugi. 

### 
