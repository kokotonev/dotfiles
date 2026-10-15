# Pipe my public key to my clipboard. Where there's no clipboard (e.g. over SSH), just print it.
if command -v pbcopy >/dev/null 2>&1
then
  alias pubkey="pbcopy < ~/.ssh/id_ed25519.pub && echo '=> Public key copied to pasteboard.'"
else
  alias pubkey="cat ~/.ssh/id_ed25519.pub"
fi
