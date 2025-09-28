TPUT 					= tput -T xterm-256color
_RESET 					:= $(shell $(TPUT) sgr0)
_BOLD 					:= $(shell $(TPUT) bold)
_ITALIC 				:= $(shell $(TPUT) sitm)
_UNDER 					:= $(shell $(TPUT) smul)
_GREEN 					:= $(shell $(TPUT) setaf 2)
_YELLOW 				:= $(shell $(TPUT) setaf 3)
_RED 					:= $(shell $(TPUT) setaf 1)
_GRAY 					:= $(shell $(TPUT) setaf 8)
_PURPLE 				:= $(shell $(TPUT) setaf 5)

up :
	@printf "\n$(_GREEN)$(_BOLD)Montage de l'image routeur$(_RESET)\n\n"
	@sudo docker build -t sabartho/routeur router/
	@printf "\n$(_GREEN)$(_BOLD)Montage de l'image host$(_RESET)\n\n"
	@sudo docker build -t sabartho/host host/

down:
	@printf "\n$(_GREEN)$(_BOLD)Demontage de l'image routeur$(_RESET)\n\n"
	@sudo docker rmi sabartho/routeur
	@printf "\n$(_GREEN)$(_BOLD)Demontage de l'image host$(_RESET)\n\n"
	@sudo docker rmi sabartho/host
