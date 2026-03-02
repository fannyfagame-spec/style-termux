# fannyfa-style-termux

This Bash script contains Oh-My-Zsh, command autosuggestion, syntax highlighting plugins, and a custom terminal header with your own name for TERMUX.

## Preview after setup completed
<img src="https://i.ibb.co.com/4Zd7Jy6t/Screenshot-2026-03-02-13-27-38-531-com-termux.jpg" width="200" height="500">

---

## This script contains popular features

- [x] Oh-My-Zsh themes  
- [x] Zsh autosuggestion plugin  
- [x] Zsh syntax highlighting plugin  
- [x] Termux banner  
- [x] PS1 with custom trim path indicator  
- [x] Custom prompt cursor  
- [ ] Git prompt (coming soon)

---

## Termux keyboard features & shortcuts

- [x] Open new session → `CTRL + t`  
- [x] Close terminal → swipe up on keyboard icon  
- [x] Switch between sessions → `CTRL + 4` and `CTRL + 5`  
- [x] Other shortcuts (see video guide)

---

## Download & Installation

<img src="https://i.ibb.co.com/LDLNVG4y/Screenshot-2026-03-02-13-27-12-478-com-termux.jpg" width="200" height="500">

1. `apt update && yes | apt upgrade && apt update && apt install git -y`
2. `git clone https://github.com/fannyfagame-spec/style-termux.git`
3. `cd style-termux`
4. `ls`
5. `bash t-header.sh`
6. After installation complete → open new session or run:
   ```
   source ~/.zshrc
   ```
7. To remove:
   ```
   cd ~/style-termux
   bash t-header.sh --remove
   exit
   ```

---

⚠️ Don't try without cloning the repository first.
