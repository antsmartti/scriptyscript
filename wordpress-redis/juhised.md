# Uuenda .env faili
```
nano .env
```

Kõige olulisem on siia kleepida enda Cloudflare token. Paroolide muutmine on valikuline, kuid **rangelt soovituslik**. 


# Lisa need read faili *wordpress-data/wp-config.php*, et Redis hakkaks tööle:
```
nano wp-config.php
```
```
define('WP_CACHE_KEY_SALT', 'your_unique_salt_here');  // Change this to something unique
define('WP_REDIS_HOST', 'redis');  // Name of your Redis container in Docker
define('WP_REDIS_PORT', 6379);     // Default Redis port
define('WP_CACHE', true);          // Enable caching
```

## Miks?

Redis taustal küll töötab, kuid Wordpress ei leia Redist üles. Esialgu otsib Wordpress teda 127.0.0.1:6379, kuid Docker'i puhul on host redis:8379.

### Näide toimivast Redisest:
![image](https://github.com/user-attachments/assets/2abc2b3d-3442-440b-9302-9181899ac639)

![image](https://github.com/user-attachments/assets/31a9cb4b-451c-472f-83b9-00aaec7600d4)
