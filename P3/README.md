## P3 — EVPN/VXLAN avec FRR (RR + Leafs) 🧠🚚

### Objectifs
- Mettre en place une petite fabrique EVPN/VXLAN dans GNS3 avec Docker.
- Rôles: un **Route Reflector (RR)** et un ou plusieurs **LEAFs** (avec hôtes en accès).
- Comprendre ce que publie EVPN (types de routes) et comment le dataplane VXLAN s’appuie sur l’underlay IP.

---

## Vision d’ensemble (overlay/underlay)
- **Underlay (L3 IP)**: connectivité entre les loopbacks des routeurs (VTEP IP). Ici on utilise OSPF pour propager ces /32.
- **Overlay (L2 VXLAN)**: domaine L2 virtuel porté par **VNI 10**. Chaque LEAF crée `vxlan10` et un **bridge** local pour attacher l’interface d’accès (vers l’hôte) et l’interface VXLAN.
- **VTEP**: l’« ouverture du dépôt » VXLAN. Son IP = **`LOOPBACK_IP`** du nœud. Les paquets vers d’autres VTEP sortent en **UDP/4789**.

Analogie: l’underlay est l’autoroute; l’overlay est le camion (VXLAN) qui transporte la trame Ethernet d’un entrepôt (LEAF) à un autre. 🛣️📦

---

## Fichiers importants et leur rôle
- `router/Dockerfile`: image routeur basée sur FRR. Installe les utilitaires réseau et copie les scripts.
- `router/scripts/entrypoint.sh`: séquence de démarrage. Lance le script VXLAN, génère `frr.conf` puis démarre FRR.
- `router/scripts/vxlan_boot.sh`: prépare le dataplane Linux:
  - crée un bridge (`br0`), 
  - crée l’interface `vxlan<VNI>` (ex: `vxlan10`) avec `local ${LOOPBACK_IP}` et l’attache au bridge,
  - met l’interface d’accès (`eth1` par défaut) dans le bridge.
- `router/scripts/bootstrap_frr.sh`: génère `/etc/frr/frr.conf` à partir des **variables d’environnement** (voir plus bas). Configure:
  - OSPF (underlay)
  - BGP + EVPN (overlay)
- `router/conf/*.conf`: exemples simples (pédagogiques). Le fichier généré par le script reste la source d’autorité au runtime.

---

## Variables d’environnement (par nœud)
Communes
- `ASN` (ex: `1`)
- `VNI` (ex: `10`)
- `LOOPBACK_IP` (IP VTEP, ex: `1.1.1.4`)

RR (`ROLE=RR`)
- `ROLE=RR`

LEAF (`ROLE=LEAF`)
- `ROLE=LEAF`
- `RR_IP` (loopback du RR, ex: `1.1.1.1`)
- `ACCESS_IF=eth1` et `UNDERLAY_IF=eth0` (par défaut)

---

## Types de routes EVPN (ce que tu vas observer) 🔍
- **Type‑3 (IMET)**: points d’entrée pour BUM (flood control). Tu devrais en voir au moins une par VNI lorsque le peering EVPN est up.
- **Type‑2 (MAC/IP)**: apprend l’emplacement d’un hôte (MAC) et son IP. Apparait dès qu’un hôte parle.
- (Optionnel) **Type‑5**: préfixes IP L3 (non utilisé dans le strict minimum de ce lab).

Commandes utiles:
```bash
vtysh -c 'show bgp summary'
vtysh -c 'show bgp l2vpn evpn'
vtysh -c 'show bgp l2vpn evpn route-type 3'
vtysh -c 'show evpn vni'
vtysh -c 'show evpn vni detail'
```

Attendu sur un leaf juste après boot (même sans hôtes):
- `show evpn vni` → VNI `10` en **Type L2**, `State Up`, `VxLAN IF vxlan10`.
- `show bgp l2vpn evpn` → **au moins 1** entrée type‑3 « advertised » vers le RR.

---

## Lancer la partie 3 (pas à pas)
1) Construire l’image routeur/host de P3:
```bash
cd P3/
make
```
2) Dans GNS3 → `Edit` → `Preferences` → `Docker containers` → **Add** les images construites (routeur + host).
3) Créer la topologie: 1 RR, au moins 2 LEAFs, chaque LEAF relié à son hôte.
4) Pour chaque nœud routeur, définir les **variables d’environnement** ci‑dessus.
5) « ▶ Lancer tous les services », puis ouvrir les consoles.

Vérifications:
```bash
# Underlay
vtysh -c 'show ip route'

# BGP EVPN
vtysh -c 'show bgp summary'
vtysh -c 'show bgp l2vpn evpn'
vtysh -c 'show evpn vni'

# Dataplane Linux
ip -br link | egrep 'br0|vxlan|eth'
ip -d link show vxlan10
bridge fdb show br0 | sort
```

Test de bout en bout (après configuration IP des hôtes dans le même VNI):
```bash
ping <ip_host_leaf1>   # depuis l'autre host
```

---

## Ce que tu apprends ici 💡
- Relier plusieurs LEAFs via un **overlay L2** tout en gardant un **underlay L3** propre.
- Lire les sorties FRR EVPN (types 2/3), comprendre l’association **VTEP ↔ VNI ↔ bridge**.

Bon lab, et amuse‑toi à ajouter des LEAFs, plusieurs VNIs, ou du **ECMP** dans l’underlay ! 🚀