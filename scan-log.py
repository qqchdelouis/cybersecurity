#!/usr/bin/env python3
# -*- coding: utf-8 -*-
# scan-log.py - Analysez le fichier pour détecter les problèmes d'adresse IP.

import sys
import os
import re
from collections import Counter

def analyze_security_logs(LOG_FILE_PATH, FAILED_LOGIN_THRESHOLD):
    print("[*] Analyse des logs en cours (Ligne par ligne)...")

    # 1/. Regex ciblée pour attraper l'IP UNIQUEMENT lors d'un échec de connexion
    # S'adapte aux lignes contenant "Failed password" ou "Invalid user"
    brute_force_pattern = re.compile(r"(?:Failed password|Invalid user).*from (\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})")

    # 2/. Initialisation d'un compteur vide
    ip_counts = Counter()

    try:
        # 3/. & 4/. Lecture ligne par ligne et comptage en temps réel
        with open(LOG_FILE_PATH, "r") as file:
            for line in file:
                match = brute_force_pattern.search(line)
                if match:
                    ip_address = match.group(1)
                    ip_counts[ip_address] += 1  # On incrémente directement le Counter
        print("\n[+] Rapport d'analyse de sécurité :")
        print("-" * 40)
        print("\n∑ : " + str(len(ip_counts)) + " adresses IP évaluées\n")
        print("-" * 40)
        # 5/. Détection des anomalies (Reste identique à votre script !)
        suspicious_activity_detected = False
        ban_list = []
        for ip, count in ip_counts.items():
            if count > FAILED_LOGIN_THRESHOLD:
                print(f"[ALERT] Activité suspecte détectée depuis l'IP : {ip} ({count} requêtes)")
                ban_list.append(str(ip))
                suspicious_activity_detected = True
        if not suspicious_activity_detected:
            print("[INFO] Aucune anomalie détectée. Toutes les IP sont sous le seuil critique.")
    except FileNotFoundError:
        print(f"[!] Erreur : Le fichier {LOG_FILE_PATH} est introuvable.")
    return ban_list

if __name__ == "__main__":
    if len(sys.argv) > 1:
        LOG_FILE_PATH = sys.argv[1]
    else:
        # 6/. Demandez le chemin d'accès et le fichier à analyser.
        LOG_FILE_PATH = input('Please provide the full path and log file to be scanned : ')
    # 7/. Contrôle de sécurité : vérifiez que le fichier existe bien avant d’exécuter l’analyseur de regex.
    if not os.path.isfile(LOG_FILE_PATH):
        print(f"[!] Erreur : Le chemin spécifié n'est pas un fichier valide : {LOG_FILE_PATH}")
        sys.exit(1)
    FAILED_LOGIN_THRESHOLD = 50  # Seuil d'alerte
    bad_ips = analyze_security_logs(LOG_FILE_PATH, FAILED_LOGIN_THRESHOLD)
    print(bad_ips)
