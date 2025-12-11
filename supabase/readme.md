## Käivita script

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/antsmartti/scriptyscript/refs/heads/main/supabase/supabase.sh)"
```

Andmebaaside paroolid genereeritakse automaatselt.

## Cloudflare seadistus
Kui uus tunnel token on genereeritud, lisa DNS jaoks järgnevad read

<img height="240" alt="Screenshot 2025-11-26 164947" src="https://github.com/user-attachments/assets/f3c24326-805a-4beb-80a1-9a9d1b787079" />

*URL on kõigil sama, erineb vaid path* 
## Võimalikud errorid
<details>
<summary>Probleemid n8n kasutamisel</summary>
Luues Supabase jaoks credential, ei õnnestunud mul tükk aega andmeid lugeda-sisestada. Jõudsin järeldasin, et probleem on Cloudflare HTTP Header'is. Lahenduse leidsin n8n foorumist ([link](https://community.n8n.io/t/105732)). Skript PEAKS selle lahendama, kuid ei pruugi. 

Kui ei lahenda, siis siin on lahendus:

> *Add the plugin that remove authorization key in the kong.yml file (you can find it in ./your-project/volumes/api/kong.yml):*
```yaml
- name: request-transformer
        config:
          remove:
            headers:
              - Authorization
```
</details>
<details>
<summary>Uus schema pole kättesaadav läbi API</summary>
Pilveversioonis on see lihtsasti lahendatav, self-hosted versiooni puhul peab seda confis tegema. 

1. Lisa uus schema failidesse ./docker/.env ja ./config.toml
2. Anna vajalikud õigused schemale ja tabelitele
```sql
-- Replace {new_schema} with your actual schema name
GRANT USAGE ON SCHEMA {new_schema} TO anon, authenticated, service_role; -- 1. Grant USAGE on the schema so the role can access objects within it
GRANT ALL ON ALL TABLES IN SCHEMA {new_schema} TO anon, authenticated, service_role; -- 2. Grant ALL PRIVILEGES (SELECT, INSERT, UPDATE, DELETE) on existing tables
GRANT ALL ON ALL SEQUENCES IN SCHEMA {new_schema} TO anon, authenticated, service_role; -- 3. Grant ALL PRIVILEGES on existing sequences (for auto-incrementing IDs/PKs)
ALTER DEFAULT PRIVILEGES IN SCHEMA {new_schema} GRANT ALL ON TABLES TO anon, authenticated, service_role; -- 4. Set default privileges for future objects
ALTER DEFAULT PRIVILEGES IN SCHEMA {new_schema} GRANT ALL ON SEQUENCES TO anon, authenticated, service_role; -- 5.This ensures any NEW tables/objects created later in this schema also get the correct permissions.
```
</details>
