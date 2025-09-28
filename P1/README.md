## P1 — Premiers pas avec GNS3 + Docker (hôte + routeur)

### À quoi sert cette partie ?
- Se familiariser avec GNS3 et l’intégration de conteneurs Docker.
- Créer deux images simples:
  - un **hôte** minimal (shell, ping…)
  - un **routeur** basé sur **FRRouting (FRR)** pour activer des services de routage (zebra, BGPd, OSPFd, ISISd)
- Manipuler l’interface GNS3: ajouter des templates Docker, poser les nœuds, les relier, démarrer et ouvrir les consoles. ✨

### Les concepts en deux mots (avec mini analogies)
- **Hôte**: un poste de travail connecté au réseau. Pense « PC de labo ».
- **Routeur**: un agent de circulation qui choisit par où faire passer les paquets entre réseaux.
- **FRR (FRRouting)**: la suite logicielle qui fait tourner les démons de routage (zebra, bgpd, ospfd, isisd). 🧠
- **GNS3**: le plateau de tournage où tu poses et relies des machines virtuelles / conteneurs.
- **Template Docker**: une fiche GNS3 qui décrit « comment lancer tel conteneur » (image, consoles, interfaces…).

### Arborescence et rôle des fichiers
- `P1/Makefile`: commandes de build pratiques pour fabriquer les images Docker locales.
- `P1/host/Dockerfile`: image de l’hôte (base Alpine), fournit un shell et les utilitaires réseau (busybox/iputils).
- `P1/router/Dockerfile`: image du routeur (base Alpine + FRR). Active les démons via `/etc/frr/daemons` et copie les scripts.
- `P1/router/conf/daemons`: fichier FRR qui déclare quels services démarrer (zebra/bgpd/ospfd/isisd = yes). 
- `P1/router/conf/{zebra.conf, bgpd.conf, ospfd.conf, isisd.conf}`: fichiers de configuration FRR (ici très simples/éducatifs).
- `P1/router/scripts/entrypoint.sh`: petit script de démarrage dans le conteneur routeur qui lance FRR.
- `P1/P1.gns3project` (et dossiers `untitled/…`): artefacts GNS3 (projet, snapshots d’interfaces, captures, etc.).

### Pré‑requis
- Linux (recommandé) avec Docker installé.
- GNS3 (client + serveur local). Sur Linux, privilégie **Docker Engine natif** plutôt que Docker Desktop pour éviter des soucis de namespaces avec uBridge.

### Build des images (rapide)
Dans la racine du dépôt:
```bash
cd P1/
make
```
Ce `make` construit les deux images locales (hôte et routeur) prêtes à être utilisées par GNS3. 🛠️

### Intégration dans GNS3 (setup)
1) Ouvre GNS3.
2) Va dans `Edit` → `Preferences` → `Docker containers`.
3) Clique sur « New » et **ajoute deux templates** en pointant sur les images construites (host + router).
   - Console: Telnet
   - Nombre d’interfaces: 1 (suffit pour le mini‑lab)
   - Capabilities: par défaut (le routeur FRR peut nécessiter `CAP_NET_ADMIN`; GNS3 sait le gérer automatiquement pour la plupart des images Alpine)
4) Valide. Les deux templates apparaissent désormais dans la liste de gauche de GNS3.

### Créer la mini topologie
1) Glisse l’hôte et le routeur dans l’aire de travail.
2) Relie l’interface de l’hôte à l’interface `eth0` du routeur (outil « Lien » dans la barre de gauche). 🔗
3) Clique sur « ▶ Lancer tous les services » pour démarrer les deux conteneurs.
4) Double‑clique chaque nœud pour ouvrir la **console Telnet**.

### Ce que tu devrais voir (exemples)
- Sur l’hôte: un shell busybox ou Alpine (`/bin/sh`), commandes `ping`, `ip`, `ifconfig`…
- Sur le routeur: des processus FRR actifs. Tu peux vérifier:
```bash
ps aux | grep -E 'zebra|bgpd|ospfd|isisd'
```

### Comprendre (un peu) FRR dans cette partie
- **zebra**: la « table de routage » de base (L3) et la gestion des interfaces.
- **bgpd/ospfd/isisd**: démons optionnels pour parler BGP/OSPF/IS‑IS. Ici, le but est surtout de valider que FRR démarre correctement et que tu peux accéder à la **console VTY** (`vtysh`) pour afficher l’état.

### Lancement express (résumé)
1) `make` dans `P1/` (ou `make -C P1` à la racine) pour construire les images.
2) Ouvrir GNS3 → `Edit` → `Preferences` → `Docker containers` → **Add** les deux images.
3) Poser 1 hôte + 1 routeur, les relier, **Lancer tous les services**.
4) Ouvrir les consoles et tester un `ping` entre eux. ✅

### Et après ?
- Dans `P2/` et `P3/`, on enrichit la topologie, on active des protocoles et on découvre EVPN/VXLAN. Pour l’instant, l’objectif est d’être à l’aise avec GNS3, Docker et les consoles. 🚀


