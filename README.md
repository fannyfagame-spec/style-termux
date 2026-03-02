# fannyfa-style-termux

This Bash script contains Oh-My-Zsh, command autosuggestion, syntax highlighting plugins, and a custom terminal header with your own name for TERMUX.

## Preview after setup completed
<img src="https://user-images.githubusercontent.com/28594846/42722171-e92e650c-8764-11e8-8f65-76a318c1de27.jpeg" width="200" height="220">

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

<img src="https://user-images.githubusercontent.com/28594846/42721978-6b90278c-8761-11e8-97f2-eca4f86e837f.jpeg" width="200" height="220">

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
