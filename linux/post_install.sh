#!/bin/bash

LIST_PKG_SPEC="tellico"
LIST_PKG_SPEC="gscan2pdf git gitk gip filezilla x2goclient sshfs"
LIST_PKG_SPEC="thunderbird"
CodeName="$(lsb_release -sc Codename 2>/dev/null)"
install_brave_browser=true
install_docker=true
install_vscode=true
install_megasync=false
install_virtualbox=false
install_vagrant=false
install_packer=false
install_teamviewer=false
install_zoom=false
install_git_repo=false

Packages="${LIST_PKG_SPEC} vim terminator geany vlc gthumb htop"

sudo apt install -yqq curl auto-apt-cacher

if ${install_git_repo}; then
	echo "## Install GIT Repo"
	test -d GitRepo || mkdir GitRepo

	sudo apt install -yqq git
	pushd GitRepo

	echo "  * Clone Debian-CIS"
	git clone https://github.com/ovh/debian-cis.git
	echo "  * Clone Jess Fraz - DockerFiles"
	git clone https://github.com/jessfraz/dockerfiles.git
	echo "  * Clone Simple HTTP Server With Upload"
	git clone https://github.com/Tallguy297/SimpleHTTPServerWithUpload.git
	echo "  * Clone unrpa"
	git clone https://github.com/Lattyware/unrpa.git
	echo "  * Clone unrpyc"
	git clone https://github.com/CensoredUsername/unrpyc.git
	echo "  * Clone Ventoy"
	git clone https://github.com/ventoy/Ventoy.git
	echo "  * Clone rpatool"
	git clone https://github.com/Shizmob/rpatool.git
	echo "  * Clone awesaome-compose"
	git clone https://github.com/docker/awesome-compose.git
	echo "  * Clone Lookyloo"
	git clone https://github.com/CIRCL/lookyloo.git
	echo "  * Clone Renpy_auto_translate"
	git clone https://github.com/creerjeuvideoseul/renpy_auto_translate.git
	echo "  * Clone Ren-Py-Novel-Translation"
	git clone https://github.com/cherifVN/Ren-Py-Novel-Translation.git
	echo "  * Clone Translate-rempy"
	git clone https://github.com/duc010298-1/translate-renpy.git
	echo "  * Clone Yamete"
	git clone https://github.com/jaymoulin/yamete.git
	popd
fi

if ${install_brave_browser}; then
	echo "## Install Brave"
	curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg
	echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg] http://brave-browser-apt-release.s3.brave.com/ stable main"|sudo tee /etc/apt/sources.list.d/brave-browser-release.list

	Packages="${Packages} \
		brave-browser \
		"
fi

if ${install_docker}; then
        echo "## Install Docker"
	curl -fsSL https://download.docker.com/linux/ubuntu/gpg |sudo gpg --dearmor --output /usr/share/keyrings/docker-archive-keyring.gpg
Packages="${Packages} \
    ca-certificates \
    "
	cat > /etc/apt/sources.list.d/docker.sources << EOF
X-Repolib-Name: Docker repo Sources
Enabled: yes
Types: deb
URIs: http://download.docker.com/linux/ubuntu
Suites: ${CodeName}
Components: stable
Architectures: amd64
Signed-By: /usr/share/keyrings/docker-archive-keyring.gpg
EOF

Packages="${Packages} \
    docker-ce docker-ce-cli docker-compose docker-compose-plugin
    "
fi

if ${install_vscode}; then
	echo "## Install vscode"
	curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor --output /usr/share/keyrings/packages.microsoft.gpg
	cat > /etc/apt/sources.list.d/vscode.sources << EOF
X-Repolib-Name: VScode repo sources
Enabled: yes
Types: deb
URIs: http://packages.microsoft.com/repos/code
Suites: stable
Components: main
Architectures: amd64
Signed-By: /usr/share/keyrings/microsoft.gpg
EOF
	
	Packages="${Packages} \
		code \
		"
fi

if ${install_megasync}; then
	echo "## Install megasync"
	MEGASYNC_xUbuntu="$(wget https://mega.nz/linux/repo -qO- |grep xUbuntu |tail -1 |sed -e 's#.* href="xU#xU#;s#/">xU.*##')"
	wget "https://mega.nz/linux/repo/${MEGASYNC_xUbuntu}/amd64/megasync-${MEGASYNC_xUbuntu}_amd64.deb" && sudo apt install "$PWD/megasync-${MEGASYNC_xUbuntu}_amd64.deb"
	rm -f "$PWD/megasync-${MEGASYNC_xUbuntu}_amd64.deb"
fi

if ${install_virtualbox}; then
	echo "## Install virtualbox"
	wget -qO- http://download.virtualbox.org/virtualbox/debian/oracle_vbox_2016.asc |sudo gpg --dearmor --output /etc/apt/trusted.gpg.d/virtualbox.gpg
	sudo apt-add-repository "deb [arch=amd64 signed-by=/etc/apt/trusted.gpg.d/virtualbox.gpg] http://download.virtualbox.org/virtualbox/debian $(lsb_release -sc) contrib"
	Packages="${Packages} \
		virtualbox-7.0 virtualbox-guest-utils \
		"
	Post_cmd="$Post_cmd; sudo usermod -G vboxusers -a $USER"
fi

if ${install_vagrant} || ${install_packer}; then
	echo "## Install packer/vagrant"
	curl -fsSL https://apt.releases.hashicorp.com/gpg |sudo gpg --dearmor --output /etc/apt/trusted.gpg.d/hashicorp.gpg
	sudo apt-add-repository "deb [arch=amd64 signed-by=/etc/apt/trusted.gpg.d/hashicorp.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
	Packages="${Packages} \
	    packer \
	    vagrant \
	    "
fi

if ${install_teamviewer}; then
	echo "## Install teamviewer"
	echo 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 | \
	    base64 -d |gunzip -c |gpg --dearmor --output /etc/apt/trusted.gpg.d/teamviewer-release.gpg
	apt-add-repository "deb [arch=amd64 signed-by=/etc/apt/trusted.gpg.d/teamviewer-release.gpg] http://linux.teamviewer.com/deb stable main"
	Packages="${Packages} \
	    teamviewer \
	    "
fi

if ${install_zoom}; then
	echo "## Install zoom"
	echo mQENBFYxWIwBCADAKoZhZlJxGNGWzqV+1OG1xiQeoowKhssGAKvd+buXCGISZJwTLXZqIcIiLP7pqdcZWtE9bSc7yBY2MalDp9Liu0KekywQ6VVX1T72NPf5Ev6x6DLV7aVWsCzUAF+eb7DC9fPuFLEdxmOEYoPjzrQ7cCnSV4JQxAqhU4T6OjbvRazGl3agOeizPXmRljMtUUttHQZnRhtlzkmwIrUivbfFPD+fEoHJ1+uIdfOzZX8/oKHKLe2jH632kvsNzJFlROVvGLYAk2WRcLu+RjjggixhwiB+Mu/A8Tf4V6b+YppS44q8EvVrM+QvY7LNSOffSO6Slsy9oisGTdfE39nC7pVRABEBAAG0N01pY3Jvc29mdCAoUmVsZWFzZSBzaWduaW5nKSA8Z3Bnc2VjdXJpdHlAbWljcm9zb2Z0LmNvbT6JATUEEwECAB8FAlYxWIwCGwMGCwkIBwMCBBUCCAMDFgIBAh4BAheAAAoJEOs+lK2+EinPGpsH/32vKy29Hg51H9dfFJMx0/a/F+5vKeCeVqimvyTM04C+XENNuSbYZ3eRPHGHFLqeMNGxsfb7C7ZxEeW7J/vSzRgHxm7ZvESisUYRFq2sgkJ+HFERNrqfci45bdhmrUsy7SWw9ybxdFOkuQoyKD3tBmiGfONQMlBaOMWdAsic965rvJsd5zYaZZFI1UwTkFXVKJt3bp3Ngn1vEYXwijGTa+FXz6GLHueJwF0I7ug34DgUkAFvAs8Hacr2DRYxL5RJXdNgj4Jd2/g6T9InmWT0hASljur+dJnzNiNCkbn9KbX7J/qK1IbR8y560yRmFsU+NdCFTW7wY0Fb1fWJ+/KTsC4= | \
	    base64 -d |sudo gpg --dearmor --output /etc/apt/trusted.gpg.d/microsoft.gpg
	sudo apt-add-repository "deb [arch=amd64 signed-by=/etc/apt/trusted.gpg.d/microsoft.gpg] http://packages.microsoft.com/repos/ms-teams stable main"
	Packages="${Packages} \
	    zoom-player \	    "
fi
	   
sudo apt update && \
	sudo apt install ${Packages} && \
	$Post_cmd
