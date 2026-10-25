# Checkpoint 03 - Cloud Native FIAP

<p align="center">
    ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣠⣶⣶⣄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀  <br>
    ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠸⣿⣿⣿⣿⠇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀  <br>
    ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣀⣤⣶⣿⣿⡏⢹⣿⣿⣶⣤⣀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀  <br>
    ⠀⠀⠀⢀⣴⣶⣶⣄⣀⣤⣶⣿⣿⣿⣿⣿⡿⠇⠸⢿⣿⣿⣿⣿⣿⣶⣤⣀⣠⣶⣶⣦⡀⠀⠀⠀  <br>
    ⠀⠀⠀⢸⣿⣿⣿⠿⣿⣿⣿⡿⠟⠉⠁⣀⣀⡀⢀⣀⣀⠈⠉⠻⢿⣿⣿⣿⠿⣿⣿⣿⡇⠀⠀⠀  <br>
    ⠀⠀⠀⠀⠙⣿⣿⣤⡀⠙⠋⢀⣠⣶⣿⣿⣿⡇⢸⣿⣿⣿⣶⣄⡀⠙⠋⢁⣤⣿⣿⠋⠀⠀⠀⠀  <br>
    ⠀⠀⠀⠀⢀⣿⣿⣿⡟⠀⣀⠈⠻⣿⣿⣿⣿⡇⢸⣿⣿⣿⣿⠟⠁⣀⠀⠻⣿⣿⣿⡀⠀⠀⠀⠀  <br>
    ⠀⠀⠀⠀⢸⣿⣿⡟⠀⣰⣿⣷⣤⡈⠙⢿⣿⡇⢸⣿⡿⠋⢁⣤⣾⣿⣆⠀⢻⣿⣿⡇⠀⠀⠀⠀  <br>
    ⠀⠀⠀⠀⣿⣿⣿⠃⠀⣿⣿⣿⣿⣿⣦⡄⠉⠀⠀⠉⣠⣴⣿⣿⣿⣿⣿⠀⠘⣿⣿⣿⠀⠀⠀⠀  <br>
    ⠀⠀⣀⣸⣿⣿⣿⡀⠀⡿⠿⠿⠛⠛⠉⢁⠀⠀⠀⠀⠈⠉⠛⠛⠿⠿⢿⠀⠀⣿⣿⣿⣇⣀⠀⠀  <br>
    ⢠⣾⣿⣿⡟⠉⠉⡀⠀⢠⣤⣴⣶⣾⣿⣿⠃⣠⣄⠈⢿⣿⣷⣶⣦⣤⡄⠀⢀⠉⠙⢻⣿⣿⣷⡄  <br>
    ⠘⢿⣿⣿⣿⣿⣿⣿⡀⠈⢿⣿⣿⣿⣿⠃⢰⣿⣿⣆⠈⣿⣿⣿⣿⡿⠁⢀⣿⣿⣿⣿⣿⣿⡿⠃  <br>
    ⠀⠀⠉⠁⠈⠻⣿⣿⣿⣄⠀⠻⣿⣿⠃⢠⣿⣿⣿⣿⣆⠘⣿⣿⠟⠀⣠⣾⣿⣿⠟⠁⠈⠉⠀⠀  <br>
    ⠀⠀⠀⠀⠀⠀⠙⢿⣿⣿⣷⣄⠀⠁⠀⠿⠿⣿⣿⠿⠿⠂⠈⠀⣠⣾⣿⣿⡿⠋⠀⠀⠀⠀⠀⠀  <br>
    ⠀⠀⠀⠀⠀⠀⠀⠀⠻⣿⣿⣿⠃⢠⣤⣤⣀⣀⣀⣀⣤⣤⡄⠘⣿⣿⣿⠟⠀⠀⠀⠀⠀⠀⠀⠀  <br>
    ⠀⠀⠀⠀⠀⠀⠀⠀⠀⣸⣿⣧⣠⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣄⣼⣿⣇⠀⠀⠀⠀⠀⠀⠀⠀⠀  <br>
    ⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⣿⣿⣿⡏⠉⠉⠉⠉⠉⠉⠉⠉⢹⣿⣿⣿⣿⠀⠀⠀⠀⠀⠀⠀⠀⠀  <br>
    ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠛⠛⠋⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠙⠛⠛⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀  <br>
</p>

</br>

Este repositório contém o **Checkpoint 03** da matéria **Cloud Native Development**.
Este repositório contém o **Checkpoint 03** da matéria **Cloud Native Development**.

O objetivo é praticar workloads batch, RBAC, segurança, empacotamento e GitOps em Kubernetes, executando os exercícios dos capítulos 8, 9, 10 e 11 da [apostila do professor](https://github.com/fabioBaraDev/cloud_developer) num cluster local com **kind** e documentando cada passo em PDF.

## Exercícios

| Exercício | Enunciado | Manifestos | Evidência |
| --- | --- | --- | --- |
| 8.1: Job paralelo com logs agregados | [README](./exercises/8.1/README.md) | [Pasta](./exercises/8.1/) | [PDF](./exercises/8.1/04-evidence.pdf) |
| 8.2: CronJob com concorrência controlada e Secret de duas formas | [README](./exercises/8.2/README.md) | [Pasta](./exercises/8.2/) | [PDF](./exercises/8.2/05-evidence.pdf) |
| 8.3: Depuração: Job estourado, Secret inválido e Service sem endpoints | [README](./exercises/8.3/README.md) | [Pasta](./exercises/8.3/) | [PDF](./exercises/8.3/12-evidence.pdf) |
| 8.4: Desafio: processamento de fila com escala a zero (KEDA) | [README](./exercises/8.4/README.md) | [Pasta](./exercises/8.4/) | [PDF](./exercises/8.4/05-evidence.pdf) |
| 9.1: ServiceAccount somente-leitura validada com can-i | [README](./exercises/9.1/README.md) | [Pasta](./exercises/9.1/) | [PDF](./exercises/9.1/04-evidence.pdf) |
| 9.2: Usuário por certificado com kubeconfig funcional | [README](./exercises/9.2/README.md) | [Pasta](./exercises/9.2/) | [PDF](./exercises/9.2/02-evidence.pdf) |
| 9.3: Depuração: quatro erros "Forbidden" reais | [README](./exercises/9.3/README.md) | [Pasta](./exercises/9.3/) | [PDF](./exercises/9.3/10-evidence.pdf) |
| 9.4: Desafio: modelo RBAC completo para quatro perfis em dois namespaces | [README](./exercises/9.4/README.md) | [Pasta](./exercises/9.4/) | [PDF](./exercises/9.4/04-evidence.pdf) |
| 10.1: Endurecimento com `securityContext` e PSA | [README](./exercises/10.1/README.md) | [Pasta](./exercises/10.1/) | [PDF](./exercises/10.1/06-evidence.pdf) |
| 10.2: Scan de vulnerabilidades e correção da imagem base | [README](./exercises/10.2/README.md) | [Pasta](./exercises/10.2/) | [PDF](./exercises/10.2/02-evidence.pdf) |
| 10.3: Depuração: aplicação matando conexões no rolling update | [README](./exercises/10.3/README.md) | [Pasta](./exercises/10.3/) | [PDF](./exercises/10.3/11-evidence.pdf) |
| 10.4: Desafio: checklist de produção + empacotamento | [README](./exercises/10.4/README.md) | [Pasta](./exercises/10.4/) | [PDF](./exercises/10.4/04-evidence.pdf) |
| 11.1: Instalar o Argo CD e sincronizar a primeira Application | [README](./exercises/11.1/README.md) | [Pasta](./exercises/11.1/) | [PDF](./exercises/11.1/05-evidence.pdf) |
| 11.2: Promoção de dev para prod por PR com Kustomize overlays | [README](./exercises/11.2/README.md) | [Pasta](./exercises/11.2/) | [PDF](./exercises/11.2/09-evidence.pdf) |
| 11.3: Depuração: Application `OutOfSync` e `Degraded` | [README](./exercises/11.3/README.md) | [Pasta](./exercises/11.3/) | [PDF](./exercises/11.3/06-evidence.pdf) |
| 11.4: Desafio: App-of-Apps/ApplicationSet + CI que atualiza a tag | [README](./exercises/11.4/README.md) | [Pasta](./exercises/11.4/) | [PDF](./exercises/11.4/14-evidence.pdf) |
