# Reverse Shell Generator - trhacknon

revgen est un générateur de payloads reverse shell en Perl, conçu pour la simplicité et la rapidité d'utilisation. Il existe en deux versions :  
- revgen.pl : Interface CLI / TUI  
- revgenweb.pl : Interface Web stylisée  

---

## Fonctionnalités

- Génération rapide de payloads reverse shell pour divers langages :
  - Bash
  - Netcat
  - Perl
  - PHP
  - Python
  - Ruby
- Interface CLI intuitive
- Interface Web interactive avec design "hacker"
- Copie rapide des payloads (version Web)
- Style personnalisé avec couleurs fluo sur fond sombre

---

## Pré-requis

- Perl installé
- Module Perl CGI pour la version Web

---

## Utilisation

### Mode CLI (revgen.pl)

    perl revgen.pl

---

### Mode Web (revgenweb.pl)

#### Méthode 1 : Avec Apache2

1. Active le module CGI :

    sudo a2enmod cgi
    sudo systemctl restart apache2

2. Copie le fichier revgenweb.pl dans le dossier CGI de ton serveur :

    sudo cp revgenweb.pl /usr/lib/cgi-bin/

3. Rends-le exécutable :

    sudo chmod +x /usr/lib/cgi-bin/revgenweb.pl

4. Accède-y dans ton navigateur :

    http://localhost/cgi-bin/revgenweb.pl

> Si Apache ne traite pas les .pl, ajoute dans la config ou un .htaccess dans /usr/lib/cgi-bin/ :

    AddHandler cgi-script .pl
    Options +ExecCGI

---

#### Méthode 2 : Avec Plackup (local)

    cp revgenweb.pl app.psgi
    plackup app.psgi

Puis ouvre : http://localhost:5000

---

## Screenshots

### Interface CLI / TUI

![CLI Screenshot](https://d.top4top.io/p_3430vfdpe1.jpg)

### Interface Web

![Web Screenshot](https://c.top4top.io/p_3430kmiih0.jpg)

---

## Auteur

**trhacknon**  
Projet open-source à but éducatif, pour démonstration de reverse shells dans un cadre légal.

---

## Avertissement

Ce projet est fourni à des fins éducatives uniquement.  
L'utilisation sur des cibles non autorisées est illégale et strictement interdite.
