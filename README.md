## BADASS — Laboratoire EVPN/VXLAN avec Docker + GNS3 (42)

### Pourquoi ce projet
- Apprendre le réseau “datacenter” moderne en construisant un mini‑fabric EVPN/VXLAN dans GNS3 avec des conteneurs Docker qui exécutent FRRouting (FRR).
- Objectif: “voir” comment les bridges, ARP, VXLAN, VTEP et BGP EVPN coopèrent, et s’exercer au dépannage comme un·e ingénieur·e réseau.

### Ce que tu vas construire (image mentale)
- Imagine chaque leaf comme un petit switch avec un port de tunnel spécial. Le tunnel, c’est VXLAN: un “camion de déménagement” qui transporte des trames Ethernet à travers un réseau IP.
- La porte du tunnel est le VTEP (VXLAN Tunnel EndPoint), identifié par une IP de loopback. Les VTEP encapsulent/décapsulent les trames.
- BGP EVPN, c’est l’annuaire intelligent: il indique à quels VTEP résident les MACs/IPs pour éviter de “crier” à tout le monde.

### Les concepts (sans douleur)
- **Bridge**: multiprise Ethernet. Les ports branchés dessus parlent en L2.
- **ARP**: “Qui a 10.0.0.7 ? Dites‑le à 10.0.0.1.” Recherche locale IP→MAC.
- **VXLAN**: un camion pour trames. Emballe des trames L2 dans UDP/4789 pour voyager sur un réseau L3.
- **VTEP**: la porte du dépôt. Chaque leaf a une IP VTEP (souvent la loopback) comme source du tunnel.
- **BUM (Broadcast/Unknown‑unicast/Multicast)**: annonces publiques. Quand on ne sait pas exactement qui joindre. EVPN gère ça proprement via les routes IMET (type‑3).
- **EVPN (famille d’adresses BGP)**: l’annuaire porté par BGP. Publie les MAC/IP (type‑2), les points d’entrée pour BUM (type‑3), etc.
- **ECMP**: plusieurs autoroutes de même longueur; le réseau peut répartir les flux.
- **Console VTY**: la CLI de FRR (`vtysh`) pour configurer et inspecter le control‑plane.

### Organisation du dépôt (vue globale)
- `P1/`, `P2/`, `P3/`: labs progressifs. `P3/` contient l’atelier EVPN/VXLAN (leaf/RR) avec Dockerfiles, scripts et exemples.
- L’image routeur est dans `P3/router/`; l’image hôte dans `P3/host/`.

### Aide‑mémoire de commandes
```bash
# Plan de contrôle FRR
vtysh -c 'show bgp summary'
vtysh -c 'show bgp l2vpn evpn'
vtysh -c 'show evpn vni'
vtysh -c 'show ip route'

# Plan de données Linux
ip -br link | egrep 'br|vxlan|eth'
ip -d link show vxlan10
bridge vlan show
```


