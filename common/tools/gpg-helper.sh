# GPG helper script for common operations

create_gpg_key() {
  local name="$1"
  local email="$2"
  local key_type="$3"
  local with_ssh="$4"

  if [[ -z "$name" || -z "$email" ]]; then
    echo "Usage: gpg-helper create <name> <email> [rsa|ed25519] [--with-ssh]"
    echo "Example: gpg-helper create \"John Doe\" \"john@example.com\" ed25519 --with-ssh"
    return 1
  fi

  key_type="${key_type:-ed25519}"

  echo "Creating GPG key for: $name <$email>"
  echo "Key type: $key_type"
  [[ "$with_ssh" == "--with-ssh" ]] && echo "SSH subkey: enabled"

  case "$key_type" in
    "ed25519")
      if [[ "$with_ssh" == "--with-ssh" ]]; then
        # Create GPG key with SSH authentication subkey
        gpg --batch --full-generate-key <<EOF
Key-Type: eddsa
Key-Curve: Ed25519
Subkey-Type: eddsa
Subkey-Curve: Ed25519
Subkey-Usage: auth
Name-Real: $name
Name-Email: $email
Expire-Date: 2y
%commit
%echo done
EOF
      else
        gpg --batch --full-generate-key <<EOF
Key-Type: eddsa
Key-Curve: Ed25519
Subkey-Type: ecdh
Subkey-Curve: Curve25519
Name-Real: $name
Name-Email: $email
Expire-Date: 2y
%commit
%echo done
EOF
      fi
      ;;
    "rsa")
      if [[ "$with_ssh" == "--with-ssh" ]]; then
        gpg --batch --full-generate-key <<EOF
Key-Type: RSA
Key-Length: 4096
Subkey-Type: RSA
Subkey-Length: 4096
Subkey-Usage: auth
Name-Real: $name
Name-Email: $email
Expire-Date: 2y
%commit
%echo done
EOF
      else
        gpg --batch --full-generate-key <<EOF
Key-Type: RSA
Key-Length: 4096
Subkey-Type: RSA
Subkey-Length: 4096
Name-Real: $name
Name-Email: $email
Expire-Date: 2y
%commit
%echo done
EOF
      fi
      ;;
    *)
      echo "Unsupported key type: $key_type"
      echo "Supported types: rsa, ed25519"
      return 1
      ;;
  esac

  echo ""
  echo "Key created successfully!"
  echo "New keys:"
  gpg --list-secret-keys --keyid-format LONG "$email"

  # Get the key ID for easier reference
  local key_id
  key_id=$(gpg --list-secret-keys --keyid-format LONG "$email" | grep "sec" | head -1 | awk '{print $2}' | cut -d'/' -f2)

  if [[ -n "$key_id" ]]; then
    echo ""
    echo "Key ID: $key_id"
    echo "To use this key for git signing, update flake.nix with:"
    echo "  gpgSigningKey = \"$key_id\";"
    echo ""
    echo "Current user: @nixUsername@"
    echo "Current email: @nixEmail@"
    echo "Current GPG key: @nixGpgSigningKey@"

    if [[ "$with_ssh" == "--with-ssh" ]]; then
      echo ""
      echo "SSH authentication subkey created!"
      echo "To use GPG for SSH authentication, the SSH subkey will be automatically available."
      echo "Check available SSH keys with: gpg-helper ssh-keys"
    fi
  fi
}

add_existing_key() {
  local key_file="$1"

  if [[ -z "$key_file" ]]; then
    echo "Usage: gpg-helper add-key <key-file>"
    echo "Example: gpg-helper add-key ~/my-secret-key.asc"
    echo ""
    echo "Note: This imports GPG keys only. For SSH keys, use ssh-add directly"
    echo "or convert SSH key to GPG format first."
    return 1
  fi

  if [[ ! -f "$key_file" ]]; then
    echo "Error: Key file '$key_file' not found"
    return 1
  fi

  echo "Importing GPG key from: $key_file"
  gpg --import "$key_file"

  if [[ $? -eq 0 ]]; then
    echo ""
    echo "Key imported successfully!"
    echo "Available secret keys:"
    gpg --list-secret-keys --keyid-format LONG
  else
    echo "Error importing key"
    return 1
  fi
}

ssh_key_info() {
  echo "=== SSH Key Management with GPG Agent ==="
  echo ""
  echo "GPG Agent SSH Support: $(systemctl --user is-active gpg-agent.service 2>/dev/null || echo "inactive")"
  echo ""

  echo "SSH keys available through GPG agent:"
  ssh-add -l 2>/dev/null || {
    echo "No SSH keys currently loaded in GPG agent"
    echo ""
    echo "To use GPG for SSH authentication:"
    echo "1. Create a GPG key with SSH subkey: gpg-helper create \"Name\" \"email\" ed25519 --with-ssh"
    echo "2. Export SSH public key: gpg --export-ssh-key KEY_ID"
    echo "3. Add to ~/.ssh/authorized_keys or GitHub/GitLab"
  }

  echo ""
  echo "Regular SSH keys (not managed by GPG):"
  if ssh-add -L >/dev/null 2>&1; then
    ssh-add -L
  else
    echo "No regular SSH keys loaded"
  fi

  echo ""
  echo "Available GPG authentication subkeys:"
  gpg --list-secret-keys --with-subkey-fingerprint | grep -A1 -B1 "\[A\]" || echo "No GPG authentication subkeys found"
}

export_ssh_key() {
  local key_id="$1"

  if [[ -z "$key_id" ]]; then
    echo "Usage: gpg-helper export-ssh <key-id>"
    echo "Example: gpg-helper export-ssh ABCD1234EFGH5678"
    echo ""
    echo "Available keys with authentication capability:"
    gpg --list-secret-keys --with-subkey-fingerprint | grep -B2 -A1 "\[A\]"
    return 1
  fi

  echo "Exporting SSH public key for GPG key: $key_id"
  gpg --export-ssh-key "$key_id" 2>/dev/null || {
    echo "Error: Could not export SSH key for $key_id"
    echo "Make sure the key has an authentication subkey ([A] usage)"
    return 1
  }
}

case "$1" in
  "backup")
    echo "Backing up GPG keys..."
    gpg --export --armor > "$HOME/gpg-public-keys.asc"
    gpg --export-secret-keys --armor > "$HOME/gpg-private-keys.asc"
    echo "Keys backed up to $HOME/gpg-*-keys.asc"
    ;;
  "list")
    echo "=== All Keys ==="
    gpg --list-keys --keyid-format LONG
    echo -e "\n=== Secret Keys ==="
    gpg --list-secret-keys --keyid-format LONG
    echo -e "\n=== PGP Export ==="
    gpg --export --armor
    ;;
  "test-sign")
    echo "Testing GPG signing..."
    echo "test" | gpg --clearsign
    ;;
  "ssh-keys")
    ssh_key_info
    ;;
  "create")
    create_gpg_key "$2" "$3" "$4" "$5"
    ;;
  "import-gpg")
    key_file="$2"

    if [[ -z "$key_file" ]]; then
      echo "Usage: gpg-helper import-gpg <key-file>"
      echo "Example: gpg-helper import-gpg ~/my-secret-key.asc"
      exit 1
    fi

    if [[ ! -f "$key_file" ]]; then
      echo "Error: Key file '$key_file' not found"
      exit 1
    fi

    echo "Importing GPG key from: $key_file"
    gpg --import "$key_file"

    if [[ $? -eq 0 ]]; then
      echo ""
      echo "GPG key imported successfully!"
      echo "Available secret keys:"
      gpg --list-secret-keys --keyid-format LONG
    else
      echo "Error importing GPG key"
      exit 1
    fi
    ;;
  "export-ssh")
    export_ssh_key "$2"
    ;;
  "current-key")
    echo "Current configuration:"
    echo "  User: @nixUsername@"
    echo "  Email: @nixEmail@"
    echo "  Home: @nixHomeDirectory@"
    echo "  GPG Key: @nixGpgSigningKey@"
    echo ""
    echo "GPG key details:"
    gpg --list-secret-keys --keyid-format LONG "@nixGpgSigningKey@" 2>/dev/null || echo "Key not found in keyring"
    ;;
  *)
    echo "Usage: gpg-helper {backup|list|test-sign|ssh-keys|create|import-gpg|export-ssh|current-key}"
    echo ""
    echo "  backup                        - Backup GPG keys to files"
    echo "  list                          - List all GPG keys with IDs"
    echo "  test-sign                     - Test GPG signing"
    echo "  ssh-keys                      - Show GPG SSH keys and authentication subkeys"
    echo "  create <name> <email> [type] [--with-ssh] - Create new GPG key (type: rsa|ed25519)"
    echo "  import-gpg <file>             - Import existing GPG key from file"
    echo "  export-ssh <key-id>           - Export SSH public key from GPG authentication subkey"
    echo "  current-key                   - Show current configuration and signing key"
    echo ""
    echo "Examples:"
    echo "  gpg-helper create \"Matthias Emde\" \"matthias@emdemail.de\" ed25519"
    echo "  gpg-helper create \"Matthias Emde\" \"matthias@emdemail.de\" ed25519 --with-ssh"
    echo "  gpg-helper export-ssh ABCD1234EFGH5678"
    echo "  gpg-helper import-gpg ~/my-gpg-key.asc"
    echo ""
    echo "IMPORTANT: GPG agent can only manage GPG keys for SSH authentication."
    echo "Regular SSH keys (.ssh/id_rsa, .ssh/id_ed25519) cannot be imported into GPG."
    echo "Use ssh-add for regular SSH keys, or create GPG keys with --with-ssh for GPG-managed SSH."
    ;;
esac
