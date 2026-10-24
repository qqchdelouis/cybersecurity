#!/bin/bash
# Modèle de renforcement de la sécurité pour Ubuntu LTS
# Remarque : exécutez ceci en tant qu'utilisateur disposant de privilèges sudo.

echo "Installing core security tools..."
sudo apt update && sudo apt install -y ufw fail2ban

echo "Configuring UFW Firewall..."
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow 22/tcp  # Change this placeholder if using a custom port
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw --force enable

# ! important
# Vous avez déjà généré une paire de clés SSH sur votre ordinateur local
# Vous avez correctement copié votre clé publique (.pub) vers votre compte utilisateur sur le VPS
# Votre clé publique (.pub) est généralement stockée dans ~/.ssh/authorized_keys
# Testez la connexion à l'aide de cette clé dans une nouvelle fenêtre de terminal, sans fermer votre session actuelle.

echo "Hardening SSH config..."
# Remplacer en toute sécurité l’authentification par mot de passe par une authentification reposant uniquement sur des clés
sudo sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
sudo sed -i 's/PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
sudo systemctl restart sshd

echo "Server hardening complete."
