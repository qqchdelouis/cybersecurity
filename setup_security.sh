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

# ==============================================================================
# SOUS-MODULE OPTIONNEL : MASQUAGE DES JETONS NGINX
# ==============================================================================
NGINX_CONF="/etc/nginx/nginx.conf"

if [ -f "$NGINX_CONF" ]; then
    echo "🛡️ [HARDENING] Nginx detected. Masking software information tokens..."
    
    # Sauvegarder le fichier de configuration maître
    cp "$NGINX_CONF" "${NGINX_CONF}.bak_$(date +%F_%T)"
    
    # Vérifiez si `server_tokens` est déjà explicitement déclaré dans le fichier.
    if grep -q "server_tokens" "$NGINX_CONF"; then
        # Ensure any active or commented server_tokens line is forced to 'off'
        sed -i 's/.*server_tokens.*/\tserver_tokens off;/g' "$NGINX_CONF"
    else
        # If it doesn't exist, inject it cleanly into the http { ... } block
        sed -i '/http {/a \\tserver_tokens off;' "$NGINX_CONF"
    fi

    # Vérifiez les paramètres de syntaxe avant d’appliquer les modifications.
    if nginx -t > /dev/null 2>&1; then
        echo "✅ [SUCCESS] Nginx syntax validation passed. Reloading daemon..."
        systemctl reload nginx
    else
        echo "❌ [ERROR] Nginx configuration syntax check failed. Reverting changes."
        mv "${NGINX_CONF}.bak_*" "$NGINX_CONF"
    fi
else
    echo "ℹ️ [INFO] Nginx configuration file not found at $NGINX_CONF. Skipping Nginx sub-routine."
fi

echo "Server hardening complete."
