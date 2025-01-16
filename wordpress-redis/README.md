## Käivita script

```
bash -c "$(curl -fsSL https://wp.anexos.ee)"
```

Andmebaaside paroolid genereeritakse automaatselt. Samuti Redise [sool](https://et.wikipedia.org/wiki/Sool_(kr%C3%BCptograafia))

### Võimalikud errorid
**unable to get image 'mysql:8.0.36': permission denied while trying to connect to the Docker daemon socket at unix:///var/run/docker.sock: Get "http://%2Fvar%2Frun%2Fdocker.sock/v1.47/images/mysql:8.0.36/json": dial unix /var/run/docker.sock: connect: permission denied**

Non-root kasutajal puuduvad õigused. Selleks lisada need ja logida uuesti sisse:
```
sudo usermod -aG docker $USER && exit
```

## Näited
### Toimiv Wordpress VPSist nähtuna:
![image](https://github.com/user-attachments/assets/cd8ad303-8a3c-4072-8735-98cdfccbfdcb)

### Toimiv Redis Wordpressist nähtuna:
![image](https://github.com/user-attachments/assets/fae99782-557e-4c1d-ae30-477139cd65b6)

*Juhin tähelepanu, et key prefix kattub sellega, mis on .env failis REDIS_SALT*

### Genereeritud .env fail:
![image](https://github.com/user-attachments/assets/23788962-7867-458a-a1ef-721d23a603a2)
